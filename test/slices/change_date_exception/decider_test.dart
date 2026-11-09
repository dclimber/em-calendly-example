import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/change_date_exception/command.dart';
import 'package:em_calendly_example/slices/change_date_exception/decider.dart';
import 'package:em_calendly_example/slices/change_date_exception/errors.dart';
import 'package:em_calendly_example/slices/change_date_exception/state.dart';
import 'package:test/test.dart';

final _schedule = ScheduleId('schedule-1');
final _host = HostId('alice-employee-id');
final _date = ExceptionDate(DateTime.utc(2027, 3, 24));
final _hours = ExceptionHours([
  ExceptionHoursRange(startTime: '09:00', endTime: '12:00'),
  ExceptionHoursRange(startTime: '13:00', endTime: '15:30'),
]);
final _created = AvailabilityScheduleCreatedEvent(
  scheduleId: _schedule,
  hostId: _host,
  scheduleName: ScheduleName('Working hours'),
  timeZone: TimeZone('Europe/Berlin'),
);
final _added = DateExceptionAddedEvent(scheduleId: _schedule, exceptionDate: _date, exceptionHours: _hours);

ChangeDateExceptionState _foldHistory(List<HostSetupEvent> history) =>
    history.fold(changeDateExceptionDecider.initialState, changeDateExceptionDecider.evolve);

Future<List<HostSetupEvent>> _decide(ChangeDateExceptionCommand command, List<HostSetupEvent> history) =>
    changeDateExceptionDecider.decide(command, _foldHistory(history)).toList();

ChangeDateExceptionCommand _with(ExceptionHours hours, {HostId? host}) => ChangeDateExceptionCommand(
  scheduleId: _schedule,
  hostId: host ?? _host,
  exceptionDate: _date,
  exceptionHours: hours,
);

DateExceptionChangedEvent _changed(ExceptionHours hours) =>
    DateExceptionChangedEvent(scheduleId: _schedule, exceptionDate: _date, exceptionHours: hours);

void main() {
  group('happy_path', () {
    // @requires date_exception_added exists for the date, and the caller is the host
    // @ensures scenario host_changes_the_hours_of_an_exception: exactly date_exception_changed with the given hours
    test('host_changes_the_hours_of_an_exception', () async {
      final changed = ExceptionHours([ExceptionHoursRange(startTime: '10:00', endTime: '11:00')]);
      expect(await _decide(_with(changed), [_created, _added]), [_changed(changed)]);
    });
  });

  group('refused_input', () {
    // @requires availability_schedule_created exists, and a range ends before it starts
    // @ensures the model's range message, no event
    test('a range that ends before it starts is refused', () async {
      final command = _with(ExceptionHours([ExceptionHoursRange(startTime: '17:00', endTime: '09:00')]));
      await expectLater(
        _decide(command, [_created, _added]),
        throwsA(
          isA<RangeMustEndAfterItStartsError>().having(
            (e) => e.message,
            'message',
            'A time range must end after it starts.',
          ),
        ),
      );
    });

    // @requires no availability_schedule_created exists for the schedule
    // @ensures the slice's not-defined message, no event
    test('a schedule that was never created is refused', () async {
      await expectLater(
        _decide(_with(_hours), const []),
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
    // @ensures the slice's host message, no event
    test('a change by someone other than the host is refused', () async {
      await expectLater(
        _decide(_with(_hours, host: HostId('bob-employee-id')), [_created, _added]),
        throwsA(
          isA<NotScheduleHostError>().having(
            (e) => e.message,
            'message',
            'Only the host of this schedule can change a date exception.',
          ),
        ),
      );
    });
  });

  group('no_current_exception', () {
    // The model states no rule for changing a date that has no exception, so the decider accepts it.
    test('a date without an exception is changed, not refused', () async {
      expect(await _decide(_with(_hours), [_created]), [_changed(_hours)]);
    });
  });
}
