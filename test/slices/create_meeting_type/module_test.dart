import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/platform/time/clock.dart';
import 'package:em_calendly_example/slices/create_meeting_type/module.dart';
import 'package:em_calendly_example/ui/paths.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';

final _schedule = AvailabilityScheduleCreatedEvent(
  scheduleId: ScheduleId('schedule-1'),
  hostId: HostId(alice.employeeId),
  scheduleName: ScheduleName('Working hours'),
  timeZone: TimeZone('Europe/Berlin'),
);

void main() {
  late TestApp t;

  setUp(() async {
    t = TestApp(slices: const [CreateMeetingTypeSlice()], ids: SequenceIdGenerator(['meeting-type-1']));
    await t.start();
  });

  // @requires alice has an availability schedule
  // @ensures the page offers the title, description, duration, location, and a schedule select, posted to meeting types
  test('new meeting type page renders the form with her schedules', () async {
    await t.given([_schedule]);
    final response = await t.get(newMeetingTypeRoute, as: alice);

    expect(response.statusCode, 200);
    expect(response.body, contains('name="meeting_title"'));
    expect(response.body, contains('name="duration_minutes"'));
    expect(response.body, contains('name="meeting_location"'));
    expect(response.body, contains('name="schedule_id"'));
    expect(response.body, contains('value="schedule-1"'));
    expect(response.body, contains('action="$meetingTypesRoute"'));
  });

  // @requires alice has no availability schedule
  // @ensures the page links to creating a schedule and renders no form
  test('new meeting type page links to a schedule when she has none', () async {
    final response = await t.get(newMeetingTypeRoute, as: alice);

    expect(response.body, contains('href="$newScheduleRoute"'));
    expect(response.body, isNot(contains('name="meeting_title"')));
  });

  // @requires alice submits a title, duration, location, and her schedule
  // @ensures the form appends meeting_type_created with the generated id and booking url, then redirects with a notice
  test('post creates the meeting type and redirects to the meeting types page', () async {
    await t.given([_schedule]);
    final response = await t.post(meetingTypesRoute, {
      'meeting_title': '30-minute consultation',
      'meeting_description': '',
      'duration_minutes': '30',
      'meeting_location': 'Room 4',
      'schedule_id': 'schedule-1',
    }, as: alice);

    expect(response.redirectPath, meetingTypesRoute);
    expect(response.notice, 'Creating your meeting type.');
    expect(
      t.events.all.last.event,
      MeetingTypeCreatedEvent(
        meetingTypeId: MeetingTypeId('meeting-type-1'),
        hostId: HostId(alice.employeeId),
        meetingTitle: MeetingTitle('30-minute consultation'),
        durationMinutes: DurationMinutes(30),
        meetingLocation: MeetingLocation('Room 4'),
        scheduleId: ScheduleId('schedule-1'),
        bookingUrl: BookingUrl('http://scheduler.test/book/meeting-type-1'),
      ),
    );
  });

  // @requires alice names no schedule that she created
  // @ensures the form appends nothing and returns the model's error to the new meeting type page
  test('post without her schedule appends nothing', () async {
    final response = await t.post(meetingTypesRoute, {
      'meeting_title': '30-minute consultation',
      'duration_minutes': '30',
      'meeting_location': 'Room 4',
      'schedule_id': 'schedule-1',
    }, as: alice);

    expect(response.redirectPath, newMeetingTypeRoute);
    expect(response.error, 'Choose an availability schedule for this meeting type.');
    expect(t.events.all, isEmpty);
  });
}
