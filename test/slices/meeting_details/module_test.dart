import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/platform/web/http.dart';
import 'package:em_calendly_example/slices/meeting_details/module.dart';
import 'package:em_calendly_example/ui/paths.dart';
import 'package:test/test.dart';

import '../../support/samples/meetings_samples.dart';
import '../../support/test_app.dart';

const _meetingId = 'f1d91c85-3a90-593b-9d5e-7cb450033766';
final _reserved = sampleMeetingsEvents().whereType<MeetingSlotReservedEvent>().single;
final _confirmed = sampleMeetingsEvents().whereType<MeetingConfirmedEvent>().single;
final _rescheduleRequested = sampleMeetingsEvents().whereType<MeetingRescheduleRequestedEvent>().single;
final _rescheduleFailed = sampleMeetingsEvents().whereType<MeetingRescheduleFailedEvent>().single;

const _stranger = Viewer(employeeId: 'dave-employee-id', name: 'Dave Outsider', email: 'dave@example.com');

void main() {
  late TestApp t;

  setUp(() async {
    t = TestApp(slices: const [MeetingDetailsSlice()]);
    await t.start();
  });

  // @requires no event has reached the meeting
  // @ensures the page says the meeting is not available yet
  test('unknown_meeting: the page says the meeting is not available yet', () async {
    final response = await t.get(meetingDetails(_meetingId), as: bob);

    expect(response.statusCode, 200);
    expect(response.body, contains('This meeting is not available yet.'));
  });

  // @requires the meeting was reserved and confirmed
  // @ensures bob, the booker, sees the title, the location, Active, and both change links
  test('confirmed_meeting_for_participant: the participant sees the details and the actions', () async {
    await t.given([_reserved, _confirmed]);
    await t.drain();
    final response = await t.get(meetingDetails(_meetingId), as: bob);

    expect(response.statusCode, 200);
    expect(response.body, contains(_reserved.meetingTitle.value));
    expect(response.body, contains(_reserved.meetingLocation.value));
    expect(response.body, contains('Active'));
    expect(response.body, contains(rescheduleSlotPicker(_meetingId)));
    expect(response.body, contains(confirmCancellation(_meetingId)));
  });

  // @requires a user who is neither the host nor the booker
  // @ensures the page is empty and shows no details
  test('non_participant_sees_nothing: a stranger gets an empty state', () async {
    await t.given([_reserved, _confirmed]);
    await t.drain();
    final response = await t.get(meetingDetails(_meetingId), as: _stranger);

    expect(response.statusCode, 200);
    expect(response.body, contains('You cannot see this meeting.'));
    expect(response.body, isNot(contains(_reserved.meetingTitle.value)));
  });

  // @requires a reschedule was requested and is still in progress
  // @ensures the page shows Change in progress and hides the change links
  test('change_in_progress_hides_actions: no change links while a change is pending', () async {
    await t.given([_reserved, _confirmed, _rescheduleRequested]);
    await t.drain();
    final response = await t.get(meetingDetails(_meetingId), as: alice);

    expect(response.body, contains('Change in progress'));
    expect(response.body, isNot(contains(confirmCancellation(_meetingId))));
  });

  // @requires a reschedule was requested and failed
  // @ensures the page shows the failure reason and the meeting is active again
  test('failed_change_shows_reason: the failure reason is visible to the host', () async {
    await t.given([_reserved, _confirmed, _rescheduleRequested, _rescheduleFailed]);
    await t.drain();
    final response = await t.get(meetingDetails(_meetingId), as: alice);

    expect(response.body, contains(_rescheduleFailed.failureReason.value));
    expect(response.body, contains('Active'));
  });
}
