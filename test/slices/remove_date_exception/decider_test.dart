import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/remove_date_exception/command.dart';
import 'package:em_calendly_example/slices/remove_date_exception/decider.dart';
import 'package:em_calendly_example/slices/remove_date_exception/errors.dart';
import 'package:em_calendly_example/slices/remove_date_exception/state.dart';
import 'package:test/test.dart';

final _schedule = ScheduleId('schedule-1');
final _host = HostId('alice-employee-id');
final _date = ExceptionDate(DateTime.utc(2027, 3, 24));
final _created = AvailabilityScheduleCreatedEvent(
  scheduleId: _schedule,
  hostId: _host,
  scheduleName: ScheduleName('Working hours'),
  timeZone: TimeZone('Europe/Berlin'),
);
final _added = DateExceptionAddedEvent(
  scheduleId: _schedule,
  exceptionDate: _date,
  exceptionHours: ExceptionHours([ExceptionHoursRange(startTime: '09:00', endTime: '12:00')]),
);

RemoveDateExceptionState _foldHistory(List<HostSetupEvent> history) =>
    history.fold(removeDateExceptionDecider.initialState, removeDateExceptionDecider.evolve);

Future<List<HostSetupEvent>> _decide(RemoveDateExceptionCommand command, List<HostSetupEvent> history) =>
    removeDateExceptionDecider.decide(command, _foldHistory(history)).toList();

RemoveDateExceptionCommand _with({HostId? host, ExceptionDate? date}) => RemoveDateExceptionCommand(
  scheduleId: _schedule,
  hostId: host ?? _host,
  exceptionDate: date ?? _date,
);

DateExceptionRemovedEvent get _removed => DateExceptionRemovedEvent(scheduleId: _schedule, exceptionDate: _date);

void main() {
  group('happy_path', () {
    // @requires date_exception_added exists for the date, and the caller is the host
    // @ensures scenario host_removes_an_exception: exactly date_exception_removed for the date
    test('host_removes_an_exception', () async {
      expect(await _decide(_with(), [_created, _added]), [_removed]);
    });
  });

  group('refused', () {
    // @requires no availability_schedule_created exists for the schedule
    // @ensures the slice's not-defined message, no event
    test('a schedule that was never created is refused', () async {
      await expectLater(
        _decide(_with(), const []),
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
    test('a removal by someone other than the host is refused', () async {
      await expectLater(
        _decide(_with(host: HostId('bob-employee-id')), [_created, _added]),
        throwsA(
          isA<NotScheduleHostError>().having(
            (e) => e.message,
            'message',
            'Only the host of this schedule can remove a date exception.',
          ),
        ),
      );
    });
  });

  group('no_current_exception', () {
    // The model states no rule for removing a date that has no exception, so the decider accepts it.
    test('a date without an exception is removed, not refused', () async {
      expect(await _decide(_with(), [_created]), [_removed]);
    });
  });

  group('property_laws', () {
    // @requires the same history and command
    // @ensures the decision is deterministic: the same inputs give the same events
    test('deciding twice gives the same events', () async {
      final history = [_created, _added];
      expect(await _decide(_with(), history), await _decide(_with(), history));
    });

    // @requires a valid history and a removal of the date
    // @ensures the decided event carries the command's schedule and date, and only those
    test('the event carries exactly the command\'s schedule and date', () async {
      final otherDate = ExceptionDate(DateTime.utc(2027, 4, 1));
      final events = await _decide(_with(date: otherDate), [_created]);
      expect(events, [DateExceptionRemovedEvent(scheduleId: _schedule, exceptionDate: otherDate)]);
    });

    // @requires any history with the schedule created
    // @ensures evolve keeps the host and the defined lifecycle, and only a creation sets them
    test('evolve sets the lifecycle and host only on creation', () {
      final afterCreate = _foldHistory([_created]);
      expect(
        afterCreate,
        RemoveDateExceptionState(lifecycle: AvailabilityScheduleLifecycleState.defined, hostId: _host),
      );
      expect(removeDateExceptionDecider.evolve(afterCreate, _added), afterCreate);
    });
  });
}
