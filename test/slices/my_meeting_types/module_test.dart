import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/platform/time/clock.dart';
import 'package:em_calendly_example/slices/create_meeting_type/module.dart';
import 'package:em_calendly_example/slices/my_meeting_types/module.dart';
import 'package:em_calendly_example/ui/paths.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';

final _meetingType = MeetingTypeId('mt-1');
const _url = 'https://scheduler.example.com/book/mt-1';

final _created = MeetingTypeCreatedEvent(
  meetingTypeId: _meetingType,
  hostId: HostId(alice.employeeId),
  meetingTitle: MeetingTitle('30-minute consultation'),
  durationMinutes: DurationMinutes(30),
  meetingLocation: MeetingLocation('Video call'),
  scheduleId: ScheduleId('sched-1'),
  bookingUrl: BookingUrl(_url),
);

void main() {
  late TestApp t;

  setUp(() async {
    t = TestApp(slices: const [MyMeetingTypesSlice()]);
    await t.start();
  });

  // @requires alice has no meeting types
  // @ensures the page shows the empty state and no table
  test('no meeting type yet: the page says so', () async {
    final response = await t.get(meetingTypesRoute, as: alice);

    expect(response.statusCode, 200);
    expect(response.body, contains('You have no meeting types yet.'));
    expect(response.body, isNot(contains(editMeetingType('mt-1'))));
  });

  // @requires alice created a meeting type
  // @ensures the page lists it with its booking link, status Active, and the disable and delete actions
  test('new meeting type has a link: the page lists it with its booking link', () async {
    await t.given([_created]);
    await t.drain();
    final response = await t.get(meetingTypesRoute, as: alice);

    expect(response.body, contains('30-minute consultation'));
    expect(response.body, contains(_url));
    expect(response.body, contains('Active'));
    expect(response.body, contains(disableMeetingType('mt-1')));
    expect(response.body, contains(deleteMeetingType('mt-1')));
  });

  // @requires alice disabled a meeting type
  // @ensures the page marks it Disabled and offers enable instead of disable
  test('disabled meeting type is marked inactive', () async {
    await t.given([_created, MeetingTypeDisabledEvent(meetingTypeId: _meetingType)]);
    await t.drain();
    final response = await t.get(meetingTypesRoute, as: alice);

    expect(response.body, contains('Disabled'));
    expect(response.body, contains(enableMeetingType('mt-1')));
    expect(response.body, isNot(contains(disableMeetingType('mt-1'))));
  });

  // @requires alice edited a meeting type
  // @ensures the page shows the new title and still the booking link
  test('edit keeps the booking link on the page', () async {
    await t.given([
      _created,
      MeetingTypeEditedEvent(
        meetingTypeId: _meetingType,
        meetingTitle: MeetingTitle('45-minute review'),
        durationMinutes: DurationMinutes(45),
        meetingLocation: MeetingLocation('Room 4'),
        scheduleId: ScheduleId('sched-1'),
      ),
    ]);
    await t.drain();
    final response = await t.get(meetingTypesRoute, as: alice);

    expect(response.body, contains('45-minute review'));
    expect(response.body, contains(_url));
  });

  // @requires alice deleted a meeting type
  // @ensures the page no longer lists it
  test('deleted meeting type disappears', () async {
    await t.given([_created, MeetingTypeDeletedEvent(meetingTypeId: _meetingType)]);
    await t.drain();
    final response = await t.get(meetingTypesRoute, as: alice);

    expect(response.body, contains('You have no meeting types yet.'));
    expect(response.body, isNot(contains(_url)));
  });

  // @requires alice created a meeting type, bob has none
  // @ensures bob's page does not show alice's meeting type
  test('viewer isolation: another host does not see the meeting type', () async {
    await t.given([_created]);
    await t.drain();
    final response = await t.get(meetingTypesRoute, as: bob);

    expect(response.body, contains('You have no meeting types yet.'));
    expect(response.body, isNot(contains(_url)));
  });

  // @requires the create meeting type slice runs with this slice
  // @ensures a posted form appears on the list
  test('posting the create form lists the new meeting type', () async {
    final app = TestApp(
      slices: const [CreateMeetingTypeSlice(), MyMeetingTypesSlice()],
      ids: SequenceIdGenerator(['mt-1']),
    );
    await app.start();
    await app.given([
      AvailabilityScheduleCreatedEvent(
        scheduleId: ScheduleId('sched-1'),
        hostId: HostId(alice.employeeId),
        scheduleName: ScheduleName('Working hours'),
        timeZone: TimeZone('Europe/Berlin'),
      ),
    ]);
    await app.post(meetingTypesRoute, {
      'meeting_title': '30-minute consultation',
      'duration_minutes': '30',
      'meeting_location': 'Video call',
      'schedule_id': 'sched-1',
    }, as: alice);
    await app.drain();
    final response = await app.get(meetingTypesRoute, as: alice);

    expect(response.body, contains('30-minute consultation'));
    expect(response.body, contains(bookingPage('mt-1')));
  });
}
