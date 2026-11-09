import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/ui/paths.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';

final _scheduleId = ScheduleId('d17055e6-8851-5fa9-9a58-12d37191a423');
final _pagePath = changeDateException(_scheduleId.value, '2027-03-24');
final _actionPath = _pagePath;

AvailabilityScheduleCreatedEvent _created({String? hostId}) => AvailabilityScheduleCreatedEvent(
  scheduleId: _scheduleId,
  hostId: HostId(hostId ?? alice.employeeId),
  scheduleName: ScheduleName('Working hours'),
  timeZone: TimeZone('Europe/Berlin'),
);

DateExceptionAddedEvent _added(List<ExceptionHoursRange> hours) => DateExceptionAddedEvent(
  scheduleId: _scheduleId,
  exceptionDate: ExceptionDate(DateTime.utc(2027, 3, 24)),
  exceptionHours: ExceptionHours(hours),
);

Iterable<DateExceptionChangedEvent> _changedEvents(TestApp t) =>
    t.events.all.map((e) => e.event).whereType<DateExceptionChangedEvent>();

void main() {
  group('happy_path', () {
    test('host_changes_the_hours_of_an_exception saves the new hours and returns to the schedules page', () async {
      final t = TestApp();
      await t.given([
        _created(),
        _added([ExceptionHoursRange(startTime: '09:00', endTime: '12:00')]),
      ]);

      final response = await t.post(_actionPath, {
        'date': '2027-03-24',
        'start_time': ['10:00'],
        'end_time': ['11:00'],
      }, as: alice);

      expect(response.redirectPath, schedulesRoute);
      expect(response.notice, isNotNull);
      expect(_changedEvents(t).single.exceptionHours.items, [
        ExceptionHoursRange(startTime: '10:00', endTime: '11:00'),
      ]);
    });
  });

  group('refused_input', () {
    test('a range that ends before it starts returns to the form with the model text', () async {
      final t = TestApp();
      await t.given([_created(), _added([])]);

      final response = await t.post(_actionPath, {
        'date': '2027-03-24',
        'start_time': ['17:00'],
        'end_time': ['09:00'],
      }, as: alice);

      expect(response.redirectPath, _pagePath);
      expect(response.error, 'A time range must end after it starts.');
      expect(_changedEvents(t), isEmpty);
    });

    test('a post by someone other than the host is refused and nothing is saved', () async {
      final t = TestApp();
      await t.given([_created(), _added([])]);

      final response = await t.post(_actionPath, {
        'date': '2027-03-24',
        'start_time': [''],
        'end_time': [''],
      }, as: bob);

      expect(response.redirectPath, _pagePath);
      expect(response.error, 'Only the host of this schedule can change a date exception.');
      expect(_changedEvents(t), isEmpty);
    });

    test('a posted date that differs from the path is refused', () async {
      final t = TestApp();
      await t.given([_created(), _added([])]);

      final response = await t.post(_actionPath, {
        'date': '2027-03-25',
        'start_time': [''],
        'end_time': [''],
      }, as: alice);

      expect(response.redirectPath, _pagePath);
      expect(response.error, 'The date of the exception cannot be changed here.');
      expect(_changedEvents(t), isEmpty);
    });
  });

  group('page', () {
    test('the host sees the date and the current hours of the exception', () async {
      final t = TestApp();
      await t.start();
      await t.given([
        _created(),
        _added([ExceptionHoursRange(startTime: '09:00', endTime: '12:00')]),
      ]);

      final response = await t.get(_pagePath, as: alice);

      expect(response.statusCode, 200);
      expect(response.body, contains('name="date"'));
      expect(response.body, contains('value="09:00"'));
      expect(response.body, contains('value="12:00"'));
    });

    test('a non-host view shows the refusal, not the form', () async {
      final t = TestApp();
      await t.start();
      await t.given([_created(), _added([])]);

      final response = await t.get(_pagePath, as: bob);

      expect(response.body, contains('Only the host of this schedule can change a date exception.'));
      expect(response.body, isNot(contains('name="start_time"')));
    });

    test('the add-exception page still answers at its own path, not this page', () async {
      final t = TestApp();
      await t.start();
      await t.given([_created()]);

      final response = await t.get(newDateException(_scheduleId.value), as: alice);

      expect(response.statusCode, 200);
      expect(response.body, isNot(contains('Change a date exception')));
    });
  });
}
