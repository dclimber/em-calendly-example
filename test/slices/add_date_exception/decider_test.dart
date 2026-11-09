import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/add_date_exception/command.dart';
import 'package:em_calendly_example/slices/add_date_exception/decider.dart';
import 'package:em_calendly_example/slices/add_date_exception/errors.dart';
import 'package:em_calendly_example/slices/add_date_exception/state.dart';
import 'package:test/test.dart';

final _schedule = ScheduleId('schedule-1');
final _host = HostId('alice-employee-id');
final _date = ExceptionDate(DateTime.utc(2027, 3, 24));
final _noHours = ExceptionHours.empty();
final _hours = ExceptionHours([
  ExceptionHoursRange(startTime: '09:00', endTime: '12:00'),
  ExceptionHoursRange(startTime: '13:00', endTime: '15:30'),
]);
final _command = AddDateExceptionCommand(
  scheduleId: _schedule,
  hostId: _host,
  exceptionDate: _date,
  exceptionHours: _noHours,
);
final _created = AvailabilityScheduleCreatedEvent(
  scheduleId: _schedule,
  hostId: _host,
  scheduleName: ScheduleName('Working hours'),
  timeZone: TimeZone('Europe/Berlin'),
);

AddDateExceptionState _foldHistory(List<HostSetupEvent> history) =>
    history.fold(addDateExceptionDecider.initialState, addDateExceptionDecider.evolve);

Future<List<HostSetupEvent>> _decide(AddDateExceptionCommand command, List<HostSetupEvent> history) =>
    addDateExceptionDecider.decide(command, _foldHistory(history)).toList();

AddDateExceptionCommand _with(ExceptionHours hours, {HostId? host}) => AddDateExceptionCommand(
  scheduleId: _schedule,
  hostId: host ?? _host,
  exceptionDate: _date,
  exceptionHours: hours,
);

DateExceptionAddedEvent _added(ExceptionHours hours) =>
    DateExceptionAddedEvent(scheduleId: _schedule, exceptionDate: _date, exceptionHours: hours);

void main() {
  group('happy_path', () {
    // @requires availability_schedule_created exists for the schedule, and the caller is its host
    // @ensures scenario host_marks_a_day_unavailable: exactly date_exception_added with empty exception_hours
    test('host_marks_a_day_unavailable', () async {
      expect(await _decide(_command, [_created]), [_added(_noHours)]);
    });
  });

  group('variant', () {
    // @requires availability_schedule_created exists for the schedule, and the caller is its host
    // @ensures scenario host_sets_different_hours_for_a_day: exactly date_exception_added with the given hours
    test('host_sets_different_hours_for_a_day', () async {
      expect(await _decide(_with(_hours), [_created]), [_added(_hours)]);
    });
  });

  group('refused_input', () {
    // @requires availability_schedule_created exists, and a range ends before it starts
    // @ensures the model's range message, no event
    test('a range that ends before it starts is refused', () async {
      final command = _with(
        ExceptionHours([ExceptionHoursRange(startTime: '17:00', endTime: '09:00')]),
      );
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
      final command = _with(ExceptionHours([ExceptionHoursRange(startTime: '09:00', endTime: '09:00')]));
      await expectLater(_decide(command, [_created]), throwsA(isA<RangeMustEndAfterItStartsError>()));
    });

    test('a range with only one time is refused', () async {
      final command = _with(ExceptionHours([ExceptionHoursRange(startTime: '09:00', endTime: '')]));
      await expectLater(_decide(command, [_created]), throwsA(isA<RangeMustEndAfterItStartsError>()));
    });

    test('a malformed time is refused', () async {
      final command = _with(ExceptionHours([ExceptionHoursRange(startTime: '9am', endTime: '17:00')]));
      await expectLater(_decide(command, [_created]), throwsA(isA<RangeMustEndAfterItStartsError>()));
    });

    test('one invalid range refuses the whole exception', () async {
      final command = _with(
        ExceptionHours([
          ExceptionHoursRange(startTime: '09:00', endTime: '10:00'),
          ExceptionHoursRange(startTime: '12:00', endTime: '11:00'),
        ]),
      );
      await expectLater(_decide(command, [_created]), throwsA(isA<RangeMustEndAfterItStartsError>()));
    });

    // @requires no availability_schedule_created exists for the schedule
    // @ensures the schedule-missing message, no event
    test('a schedule that was never created is refused', () async {
      await expectLater(_decide(_command, []), throwsA(isA<ScheduleNotDefinedError>()));
    });

    test('only the host may add an exception', () async {
      final command = _with(_noHours, host: HostId('bob-employee-id'));
      await expectLater(_decide(command, [_created]), throwsA(isA<NotScheduleHostError>()));
    });
  });

  group('laws', () {
    // @requires state == fold(initialState, given)
    // @ensures decide(command, state) emits then, and decide is deterministic
    test('decide is deterministic', () async {
      expect(await _decide(_command, [_created]), await _decide(_command, [_created]));
    });

    // @ensures a refused command emits no events
    test('a refused command yields no event', () async {
      final command = _with(ExceptionHours([ExceptionHoursRange(startTime: '17:00', endTime: '09:00')]));
      final emitted = <HostSetupEvent>[];
      await expectLater(
        addDateExceptionDecider.decide(command, _foldHistory([_created])).forEach(emitted.add),
        throwsA(isA<AddDateExceptionError>()),
      );
      expect(emitted, isEmpty);
    });

    // @ensures fold(s0, a ++ b) == fold(fold(s0, a), b)
    test('fold preserves order', () {
      final history = [_created];
      final whole = [...history].fold(addDateExceptionDecider.initialState, addDateExceptionDecider.evolve);
      final stepwise = <HostSetupEvent>[_created].fold(
        addDateExceptionDecider.initialState,
        addDateExceptionDecider.evolve,
      );
      expect(stepwise, whole);
      expect(_foldHistory([_created, _added(_hours)]), _foldHistory([_created]));
    });

    test('equal commands and states are equal', () {
      expect(_command, _with(_noHours));
      expect(_command.hashCode, _with(_noHours).hashCode);
      expect(_foldHistory([_created]), _foldHistory([_created]));
      expect(_foldHistory([_created]).hashCode, _foldHistory([_created]).hashCode);
    });
  });
}
