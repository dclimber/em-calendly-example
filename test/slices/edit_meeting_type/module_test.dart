import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/edit_meeting_type/module.dart';
import 'package:em_calendly_example/ui/paths.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';

final _host = HostId(alice.employeeId);
final _schedule = AvailabilityScheduleCreatedEvent(
  scheduleId: ScheduleId('schedule-1'),
  hostId: _host,
  scheduleName: ScheduleName('Working hours'),
  timeZone: TimeZone('Europe/Berlin'),
);
final _created = MeetingTypeCreatedEvent(
  meetingTypeId: MeetingTypeId('meeting-type-1'),
  hostId: _host,
  meetingTitle: MeetingTitle('30-minute consultation'),
  durationMinutes: DurationMinutes(30),
  meetingLocation: MeetingLocation('Room 4'),
  scheduleId: ScheduleId('schedule-1'),
  bookingUrl: BookingUrl('http://scheduler.test/book/meeting-type-1'),
);
const _editPath = '/meeting-types/meeting-type-1/edit';

void main() {
  late TestApp t;

  setUp(() async {
    t = TestApp(slices: const [EditMeetingTypeSlice()]);
    await t.start();
  });

  // @requires alice created the meeting type and her schedule exists
  // @ensures the page is prefilled with the latest values and posts to the meeting type's edit route
  test('edit page renders the form prefilled from the meeting type', () async {
    await t.given([_schedule, _created]);
    final response = await t.get(_editPath, as: alice);

    expect(response.statusCode, 200);
    expect(response.body, contains('value="30-minute consultation"'));
    expect(response.body, contains('value="Room 4"'));
    expect(response.body, contains('value="30"'));
    expect(response.body, contains('value="schedule-1" selected'));
    expect(response.body, contains('action="$_editPath"'));
  });

  // @requires bob is not the host of the meeting type
  // @ensures the page renders the refusal and no form
  test('edit page refuses a viewer who is not the host', () async {
    await t.given([_schedule, _created]);
    final response = await t.get(_editPath, as: bob);

    expect(response.body, contains('Only the host of this meeting type can edit it.'));
    expect(response.body, isNot(contains('name="meeting_title"')));
  });

  // @requires alice's meeting type exists and is not deleted
  // @ensures the form appends meeting_type_edited with the submitted fields and redirects with a notice
  test('post edits the meeting type and redirects to the meeting types page', () async {
    await t.given([_schedule, _created]);
    final response = await t.post(_editPath, {
      'meeting_title': '60-minute consultation',
      'meeting_description': 'Longer slot',
      'duration_minutes': '60',
      'meeting_location': 'Room 5',
      'schedule_id': 'schedule-1',
    }, as: alice);

    expect(response.redirectPath, meetingTypesRoute);
    expect(response.notice, 'Saving your meeting type.');
    expect(
      t.events.all.last.event,
      MeetingTypeEditedEvent(
        meetingTypeId: MeetingTypeId('meeting-type-1'),
        meetingTitle: MeetingTitle('60-minute consultation'),
        durationMinutes: DurationMinutes(60),
        meetingLocation: MeetingLocation('Room 5'),
        scheduleId: ScheduleId('schedule-1'),
        meetingDescription: MeetingDescription('Longer slot'),
      ),
    );
  });

  // @requires alice's meeting type was deleted
  // @ensures the form appends nothing and returns the model's error to the edit form
  test('post on a deleted meeting type appends nothing', () async {
    await t.given([
      _schedule,
      _created,
      MeetingTypeDeletedEvent(meetingTypeId: MeetingTypeId('meeting-type-1')),
    ]);
    final before = t.events.all.length;
    final response = await t.post(_editPath, {
      'meeting_title': '60-minute consultation',
      'duration_minutes': '60',
      'meeting_location': 'Room 5',
      'schedule_id': 'schedule-1',
    }, as: alice);

    expect(response.redirectPath, _editPath);
    expect(response.error, 'A deleted meeting type cannot be edited.');
    expect(t.events.all.length, before);
  });
}
