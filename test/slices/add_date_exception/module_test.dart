import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/ui/paths.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';

final _scheduleId = ScheduleId('d17055e6-8851-5fa9-9a58-12d37191a423');
final _formPath = newDateException(_scheduleId.value);
final _actionPath = dateExceptionsAction(_scheduleId.value);

AvailabilityScheduleCreatedEvent _created() => AvailabilityScheduleCreatedEvent(
  scheduleId: _scheduleId,
  hostId: HostId(alice.employeeId),
  scheduleName: ScheduleName('Working hours'),
  timeZone: TimeZone('Europe/Berlin'),
);

Iterable<DateExceptionAddedEvent> _addedEvents(TestApp t) =>
    t.events.all.map((e) => e.event).whereType<DateExceptionAddedEvent>();

void main() {
  group('happy_path', () {
    test('host_marks_a_day_unavailable saves an exception with no hours and returns to the schedules page', () async {
      final t = TestApp();
      await t.given([_created()]);

      final response = await t.post(_actionPath, {
        'date': '2027-03-24',
        'start_time': ['', '', ''],
        'end_time': ['', '', ''],
      }, as: alice);

      expect(response.redirectPath, schedulesRoute);
      expect(response.notice, isNotNull);
      expect(_addedEvents(t).map((e) => e.exceptionHours.items), [isEmpty]);
      expect(_addedEvents(t).single.exceptionDate, ExceptionDate(DateTime.utc(2027, 3, 24)));
    });
  });

  group('variant: host_sets_different_hours_for_a_day', () {
    test('the given hour ranges are saved with the date', () async {
      final t = TestApp();
      await t.given([_created()]);

      final response = await t.post(_actionPath, {
        'date': '2027-03-24',
        'start_time': ['09:00', '', '13:00'],
        'end_time': ['12:00', '', '15:30'],
      }, as: alice);

      expect(response.error, isNull);
      expect(_addedEvents(t).single.exceptionHours.items, [
        ExceptionHoursRange(startTime: '09:00', endTime: '12:00'),
        ExceptionHoursRange(startTime: '13:00', endTime: '15:30'),
      ]);
    });
  });

  group('refused_input', () {
    test('a range that ends before it starts returns to the form with the model text', () async {
      final t = TestApp();
      await t.given([_created()]);

      final response = await t.post(_actionPath, {
        'date': '2027-03-24',
        'start_time': ['17:00'],
        'end_time': ['09:00'],
      }, as: alice);

      expect(response.redirectPath, _formPath);
      expect(response.error, 'A time range must end after it starts.');
      expect(_addedEvents(t), isEmpty);
    });

    test('a schedule that was never created is refused', () async {
      final t = TestApp();
      await t.start();

      final response = await t.post(_actionPath, {
        'date': '2027-03-24',
        'start_time': [''],
        'end_time': [''],
      }, as: alice);

      expect(response.redirectPath, _formPath);
      expect(response.error, 'This availability schedule does not exist.');
      expect(_addedEvents(t), isEmpty);
    });

    test('a post by someone other than the host is refused and nothing is saved', () async {
      final t = TestApp();
      await t.given([_created()]);

      final response = await t.post(_actionPath, {
        'date': '2027-03-24',
        'start_time': [''],
        'end_time': [''],
      }, as: bob);

      expect(response.redirectPath, _formPath);
      expect(response.error, 'Only the host of this schedule can add a date exception.');
      expect(_addedEvents(t), isEmpty);
    });

    test('an invalid date returns to the form with the input message', () async {
      final t = TestApp();
      await t.given([_created()]);

      final response = await t.post(_actionPath, {
        'date': '2027-02-30',
        'start_time': [''],
        'end_time': [''],
      }, as: alice);

      expect(response.redirectPath, _formPath);
      expect(response.error, isNotNull);
      expect(_addedEvents(t), isEmpty);
    });
  });

  group('page', () {
    test('the host sees the date and three hour rows', () async {
      final t = TestApp();
      await t.start();
      await t.given([_created()]);

      final response = await t.get(_formPath, as: alice);

      expect(response.statusCode, 200);
      expect(response.body, contains('name="date"'));
      expect(RegExp('name="start_time"').allMatches(response.body), hasLength(3));
      expect(RegExp('name="end_time"').allMatches(response.body), hasLength(3));
    });

    test('a non-host view shows the refusal, not the form', () async {
      final t = TestApp();
      await t.start();
      await t.given([_created()]);

      final response = await t.get(_formPath, as: bob);

      expect(response.body, contains('Only the host of this schedule can add a date exception.'));
      expect(response.body, isNot(contains('name="date"')));
    });
  });
}
