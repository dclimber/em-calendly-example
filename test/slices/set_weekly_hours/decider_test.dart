import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/set_weekly_hours/command.dart';
import 'package:em_calendly_example/slices/set_weekly_hours/decider.dart';
import 'package:em_calendly_example/slices/set_weekly_hours/errors.dart';
import 'package:em_calendly_example/slices/set_weekly_hours/state.dart';
import 'package:test/test.dart';

final _schedule = ScheduleId('schedule-1');
final _host = HostId('alice-employee-id');
final _hours = WeeklyHours([
  WeeklyHoursEntry(weekday: 'Monday', startTime: '09:00', endTime: '17:00'),
  WeeklyHoursEntry(weekday: 'Friday', startTime: '09:00', endTime: '13:00'),
]);
final _command = SetWeeklyHoursCommand(scheduleId: _schedule, hostId: _host, weeklyHours: _hours);
final _created = AvailabilityScheduleCreatedEvent(
  scheduleId: _schedule,
  hostId: _host,
  scheduleName: ScheduleName('Working hours'),
  timeZone: TimeZone('Europe/Berlin'),
);
final _setEvent = WeeklyHoursSetEvent(scheduleId: _schedule, weeklyHours: _hours);

SetWeeklyHoursState _foldHistory(List<HostSetupEvent> history) =>
    history.fold(setWeeklyHoursDecider.initialState, setWeeklyHoursDecider.evolve);

Future<List<HostSetupEvent>> _decide(SetWeeklyHoursCommand command, List<HostSetupEvent> history) =>
    setWeeklyHoursDecider.decide(command, _foldHistory(history)).toList();

SetWeeklyHoursCommand _with(List<WeeklyHoursEntry> entries, {HostId? host}) => SetWeeklyHoursCommand(
  scheduleId: _schedule,
  hostId: host ?? _host,
  weeklyHours: WeeklyHours(entries),
);

void main() {
  group('happy_path', () {
    // @requires availability_schedule_created exists for the schedule, and the caller is its host
    // @ensures scenario host_sets_weekly_hours: exactly weekly_hours_set with the command's fields
    test('host_sets_weekly_hours', () async {
      expect(await _decide(_command, [_created]), [_setEvent]);
    });
  });

  group('refused_input', () {
    // @requires availability_schedule_created exists, and a range ends before it starts
    // @ensures scenario range_must_end_after_it_starts: the model's error, no event
    test('range_must_end_after_it_starts', () async {
      final command = _with([WeeklyHoursEntry(weekday: 'Monday', startTime: '17:00', endTime: '09:00')]);
      await expectLater(
        _decide(command, [_created]),
        throwsA(
          isA<RangeMustEndAfterItStartsError>().having(
            (e) => e.message,
            'message',
            'A time range must end after it starts.',
          ),
        ),
      );
    });

    test('an end equal to the start is refused', () async {
      final command = _with([WeeklyHoursEntry(weekday: 'Monday', startTime: '09:00', endTime: '09:00')]);
      await expectLater(_decide(command, [_created]), throwsA(isA<RangeMustEndAfterItStartsError>()));
    });

    test('a row with only one time is refused', () async {
      final command = _with([WeeklyHoursEntry(weekday: 'Monday', startTime: '09:00', endTime: '')]);
      await expectLater(_decide(command, [_created]), throwsA(isA<RangeMustEndAfterItStartsError>()));
    });

    test('a malformed time is refused', () async {
      final command = _with([WeeklyHoursEntry(weekday: 'Monday', startTime: '9am', endTime: '17:00')]);
      await expectLater(_decide(command, [_created]), throwsA(isA<RangeMustEndAfterItStartsError>()));
    });

    test('the schedule must not be missing', () async {
      await expectLater(_decide(_command, []), throwsA(isA<ScheduleNotDefinedError>()));
    });

    test('only the host may set the hours', () async {
      final command = _with(_hours.items, host: HostId('bob-employee-id'));
      await expectLater(_decide(command, [_created]), throwsA(isA<NotScheduleHostError>()));
    });
  });

  group('variant: new_hours_leave_booked_meetings_alone', () {
    // The meeting_confirmed event belongs to the meetings context and is not in this decider's history. The
    // decision needs only the schedule's own events; the wiring test checks that the booking is left alone.
    // @ensures scenario new_hours_leave_booked_meetings_alone: weekly_hours_set, nothing about meetings
    test('weekly_hours_set is decided with the schedule history alone', () async {
      expect(await _decide(_command, [_created]), [_setEvent]);
    });
  });

  group('laws', () {
    test('decide is deterministic', () async {
      expect(await _decide(_command, [_created]), await _decide(_command, [_created]));
    });

    test('a refused command yields no event', () async {
      final command = _with([WeeklyHoursEntry(weekday: 'Monday', startTime: '17:00', endTime: '09:00')]);
      await expectLater(_decide(command, [_created]), throwsA(isA<SetWeeklyHoursError>()));
    });

    test('fold order: only the schedule creation sets the lifecycle and the host', () {
      final state = _foldHistory([_setEvent, _created]);
      expect(state, SetWeeklyHoursState(lifecycle: AvailabilityScheduleLifecycleState.defined, hostId: _host));
      expect(_foldHistory([_created, _setEvent]), state);
    });

    test('equal commands and states are equal', () {
      expect(_command, _with(_hours.items));
      expect(_command.hashCode, _with(_hours.items).hashCode);
      expect(_foldHistory([_created]), _foldHistory([_created]));
      expect(_foldHistory([_created]).hashCode, _foldHistory([_created]).hashCode);
    });
  });
}
