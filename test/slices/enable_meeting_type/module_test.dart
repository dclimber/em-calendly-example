import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/enable_meeting_type/module.dart';
import 'package:em_calendly_example/ui/paths.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';

final _host = HostId(alice.employeeId);
final _created = MeetingTypeCreatedEvent(
  meetingTypeId: MeetingTypeId('meeting-type-1'),
  hostId: _host,
  meetingTitle: MeetingTitle('30-minute consultation'),
  durationMinutes: DurationMinutes(30),
  meetingLocation: MeetingLocation('Room 4'),
  scheduleId: ScheduleId('schedule-1'),
  bookingUrl: BookingUrl('http://scheduler.test/app/book/meeting-type-1'),
);
final _disabled = MeetingTypeDisabledEvent(meetingTypeId: MeetingTypeId('meeting-type-1'));
final _enabled = MeetingTypeEnabledEvent(meetingTypeId: MeetingTypeId('meeting-type-1'));
final _deleted = MeetingTypeDeletedEvent(meetingTypeId: MeetingTypeId('meeting-type-1'));
final _path = enableMeetingType('meeting-type-1');

void main() {
  late TestApp t;

  setUp(() async {
    t = TestApp(slices: const [EnableMeetingTypeSlice()]);
    await t.start();
  });

  // @requires alice created the meeting type and disabled it
  // @ensures the post appends meeting_type_enabled and redirects to the meeting types page with a notice
  test('post enables the disabled meeting type and redirects with a notice', () async {
    await t.given([_created, _disabled]);
    final response = await t.post(_path, {}, as: alice);

    expect(response.redirectPath, meetingTypesRoute);
    expect(response.notice, 'Enabling your meeting type.');
    expect(t.events.all.last.event, _enabled);
  });

  // @requires alice deleted the meeting type
  // @ensures the post appends nothing and redirects to the meeting types page with the model's refusal
  test('post for a deleted meeting type appends nothing', () async {
    await t.given([_created, _deleted]);
    final before = t.events.all.length;
    final response = await t.post(_path, {}, as: alice);

    expect(response.redirectPath, meetingTypesRoute);
    expect(response.error, 'A deleted meeting type cannot be enabled.');
    expect(t.events.all.length, before);
  });

  // @requires bob is not the host of the meeting type
  // @ensures the post appends nothing and redirects to the meeting types page with the refusal
  test('post by a viewer who is not the host appends nothing', () async {
    await t.given([_created, _disabled]);
    final before = t.events.all.length;
    final response = await t.post(_path, {}, as: bob);

    expect(response.redirectPath, meetingTypesRoute);
    expect(response.error, 'Only the host of this meeting type can enable it.');
    expect(t.events.all.length, before);
  });
}
