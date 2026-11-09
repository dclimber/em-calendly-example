import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/ui/paths.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';

final _scheduleId = ScheduleId('d17055e6-8851-5fa9-9a58-12d37191a423');
final _path = weeklyHours(_scheduleId.value);

AvailabilityScheduleCreatedEvent _created() => AvailabilityScheduleCreatedEvent(
  scheduleId: _scheduleId,
  hostId: HostId(alice.employeeId),
  scheduleName: ScheduleName('Working hours'),
  timeZone: TimeZone('Europe/Berlin'),
);

void main() {
  group('happy_path', () {
    test('host_sets_weekly_hours saves the hours and returns to the schedules page', () async {
      final t = TestApp();
      await t.given([_created()]);

      final response = await t.post(_path, {
        'weekday': ['Monday', 'Friday'],
        'start_time': ['09:00', '09:00'],
        'end_time': ['17:00', '13:00'],
      }, as: alice);

      expect(response.redirectPath, schedulesRoute);
      expect(response.notice, isNotNull);
      final stored = t.events.all.map((e) => e.event).last;
      expect(stored, isA<WeeklyHoursSetEvent>());
      expect((stored as WeeklyHoursSetEvent).weeklyHours.items.map((e) => e.weekday), ['Monday', 'Friday']);
    });
  });

  group('refused_input', () {
    test('range_must_end_after_it_starts returns to the form with the model text', () async {
      final t = TestApp();
      await t.given([_created()]);

      final response = await t.post(_path, {
        'weekday': ['Monday'],
        'start_time': ['17:00'],
        'end_time': ['09:00'],
      }, as: alice);

      expect(response.redirectPath, _path);
      expect(response.error, 'A time range must end after it starts.');
      expect(t.events.all.map((e) => e.event).whereType<WeeklyHoursSetEvent>(), isEmpty);
    });

    test('a bookers post is refused and nothing is saved', () async {
      final t = TestApp();
      await t.given([_created()]);

      final response = await t.post(_path, {
        'weekday': ['Monday'],
        'start_time': ['09:00'],
        'end_time': ['17:00'],
      }, as: bob);

      expect(response.redirectPath, _path);
      expect(response.error, isNotNull);
      expect(t.events.all.map((e) => e.event).whereType<WeeklyHoursSetEvent>(), isEmpty);
    });
  });

  group('variant: new_hours_leave_booked_meetings_alone', () {
    // @ensures the booking is not in the schedule's stream; only weekly_hours_set is appended
    test('a confirmed meeting outside the new hours stays as booked', () async {
      final t = TestApp();
      await t.given([
        _created(),
        MeetingConfirmedEvent(
          meetingId: MeetingId('f1d91c85-3a90-593b-9d5e-7cb450033766'),
          calendarEventId: CalendarEventId('evt-7f3a9c'),
        ),
      ]);

      final response = await t.post(_path, {
        'weekday': ['Monday'],
        'start_time': ['09:00'],
        'end_time': ['10:00'],
      }, as: alice);

      expect(response.error, isNull);
      final appended = t.events.all.map((e) => e.event).skip(2).toList();
      expect(appended, hasLength(1));
      expect(appended.single, isA<WeeklyHoursSetEvent>());
    });
  });

  group('page', () {
    test('the host sees the form prefilled from the saved hours', () async {
      final t = TestApp();
      await t.start();
      await t.given([
        _created(),
        WeeklyHoursSetEvent(
          scheduleId: _scheduleId,
          weeklyHours: WeeklyHours([WeeklyHoursEntry(weekday: 'Monday', startTime: '09:00', endTime: '17:00')]),
        ),
      ]);

      final response = await t.get(_path, as: alice);

      expect(response.statusCode, 200);
      expect(response.body, contains('value="09:00"'));
      expect(response.body, contains('value="17:00"'));
    });

    test('a bookers view shows the refusal, not the form', () async {
      final t = TestApp();
      await t.start();
      await t.given([_created()]);

      final response = await t.get(_path, as: bob);

      expect(response.body, contains('Only the host of this schedule can set its weekly hours.'));
      expect(response.body, isNot(contains('name="start_time"')));
    });
  });
}
