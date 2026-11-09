import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/set_booking_limits/command.dart';
import 'package:em_calendly_example/slices/set_booking_limits/decider.dart';
import 'package:em_calendly_example/slices/set_booking_limits/errors.dart';
import 'package:em_calendly_example/slices/set_booking_limits/state.dart';
import 'package:test/test.dart';

final _schedule = ScheduleId('schedule-1');
final _host = HostId('alice-employee-id');
final _command = SetBookingLimitsCommand(
  scheduleId: _schedule,
  hostId: _host,
  bookingWindowDays: BookingWindowDays(60),
  minimumNoticeMinutes: MinimumNoticeMinutes(120),
  bufferBeforeMinutes: BufferBeforeMinutes(10),
  bufferAfterMinutes: BufferAfterMinutes(15),
);
final _created = AvailabilityScheduleCreatedEvent(
  scheduleId: _schedule,
  hostId: _host,
  scheduleName: ScheduleName('Working hours'),
  timeZone: TimeZone('Europe/Berlin'),
);
final _limitsSet = BookingLimitsSetEvent(
  scheduleId: _schedule,
  bookingWindowDays: BookingWindowDays(60),
  minimumNoticeMinutes: MinimumNoticeMinutes(120),
  bufferBeforeMinutes: BufferBeforeMinutes(10),
  bufferAfterMinutes: BufferAfterMinutes(15),
);

SetBookingLimitsState _foldHistory(List<HostSetupEvent> history) =>
    history.fold(setBookingLimitsDecider.initialState, setBookingLimitsDecider.evolve);

Future<List<HostSetupEvent>> _decide(SetBookingLimitsCommand command, List<HostSetupEvent> history) =>
    setBookingLimitsDecider.decide(command, _foldHistory(history)).toList();

SetBookingLimitsCommand _with({HostId? host, int window = 60}) => SetBookingLimitsCommand(
  scheduleId: _schedule,
  hostId: host ?? _host,
  bookingWindowDays: BookingWindowDays(window),
  minimumNoticeMinutes: MinimumNoticeMinutes(120),
  bufferBeforeMinutes: BufferBeforeMinutes(10),
  bufferAfterMinutes: BufferAfterMinutes(15),
);

void main() {
  group('happy_path', () {
    // @requires availability_schedule_created exists for the schedule, and the caller is its host
    // @ensures scenario host_sets_booking_limits: exactly booking_limits_set with the command's fields
    test('host_sets_booking_limits', () async {
      expect(await _decide(_command, [_created]), [_limitsSet]);
    });

    test('a later set replaces the earlier one in the decision, which emits only the new event', () async {
      final earlier = _limitsSet;
      expect(await _decide(_with(window: 30), [_created, earlier]), [
        BookingLimitsSetEvent(
          scheduleId: _schedule,
          bookingWindowDays: BookingWindowDays(30),
          minimumNoticeMinutes: MinimumNoticeMinutes(120),
          bufferBeforeMinutes: BufferBeforeMinutes(10),
          bufferAfterMinutes: BufferAfterMinutes(15),
        ),
      ]);
    });
  });

  group('refused', () {
    // @requires no availability_schedule_created for the schedule
    // @ensures the lifecycle rule of transition set_booking_limits: refused, no event
    test('the schedule must not be missing', () async {
      await expectLater(_decide(_command, []), throwsA(isA<ScheduleNotDefinedError>()));
    });

    test('the missing schedule is refused with its message', () async {
      await expectLater(
        _decide(_command, []),
        throwsA(
          isA<ScheduleNotDefinedError>().having(
            (e) => e.message,
            'message',
            'This availability schedule does not exist.',
          ),
        ),
      );
    });

    // @requires availability_schedule_created exists, and the caller is not its host
    // @ensures the caller is refused, no event
    test('only the host may set the limits', () async {
      await expectLater(
        _decide(_with(host: HostId('bob-employee-id')), [_created]),
        throwsA(isA<NotScheduleHostError>()),
      );
    });
  });

  group('laws', () {
    // @requires state == fold(initialState, given)
    // @ensures decide(command, state) emits then, the same on every call
    test('decide is deterministic', () async {
      expect(await _decide(_command, [_created]), await _decide(_command, [_created]));
    });

    // @requires state == fold(initialState, given)
    // @ensures decide(command, state) throws the error and emits no events
    test('a refused command yields no event', () async {
      final state = _foldHistory([]);
      final emitted = <HostSetupEvent>[];
      await expectLater(
        setBookingLimitsDecider.decide(_command, state).forEach(emitted.add),
        throwsA(isA<SetBookingLimitsError>()),
      );
      expect(emitted, isEmpty);
    });

    // @ensures fold(s0, a ++ b) == fold(fold(s0, a), b)
    test('fold preserves order, and the creation sets the lifecycle and the host', () {
      final history = <HostSetupEvent>[_created, _limitsSet];
      final decider = setBookingLimitsDecider;
      for (var split = 0; split <= history.length; split++) {
        final a = history.sublist(0, split);
        final b = history.sublist(split);
        final whole = [...a, ...b].fold(decider.initialState, decider.evolve);
        final stepwise = b.fold(a.fold(decider.initialState, decider.evolve), decider.evolve);
        expect(stepwise, whole);
      }
      expect(
        _foldHistory([_limitsSet, _created]),
        SetBookingLimitsState(lifecycle: AvailabilityScheduleLifecycleState.defined, hostId: _host),
      );
    });

    test('equal commands and states are equal', () {
      expect(_command, _with());
      expect(_command.hashCode, _with().hashCode);
      expect(_foldHistory([_created]), _foldHistory([_created]));
      expect(_foldHistory([_created]).hashCode, _foldHistory([_created]).hashCode);
    });
  });
}
