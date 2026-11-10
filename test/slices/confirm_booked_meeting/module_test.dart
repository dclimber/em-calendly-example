import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/confirm_booked_meeting/module.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';
import 'fixtures.dart';

List<MeetingConfirmedEvent> _confirmed(TestApp t) =>
    t.events.all.map((e) => e.event).whereType<MeetingConfirmedEvent>().toList();

void main() {
  // @requires a meeting reserved and still pending_calendar, and the calendar event created for it
  // @ensures the application records exactly one meeting_confirmed for the meeting, with the calendar event id
  test('created calendar event confirms the meeting once', () async {
    final t = TestApp(slices: const [ConfirmBookedMeetingSlice()]);
    await t.start();

    await t.given([reservedEvent(), requestedEvent(), createdEvent()]);
    await t.drain();
    final confirmed = _confirmed(t);
    expect(confirmed, hasLength(1));
    expect(confirmed.single.meetingId, MeetingId('meeting-1'));
    expect(confirmed.single.calendarEventId, CalendarEventId('cal-1'));

    await t.drain();
    expect(_confirmed(t), hasLength(1));
  });

  // @requires the same calendar event delivered again after the meeting was confirmed
  // @ensures the redelivery adds nothing: still one meeting_confirmed
  test('a redelivered calendar event adds nothing', () async {
    final t = TestApp(slices: const [ConfirmBookedMeetingSlice()]);
    await t.start();

    await t.given([reservedEvent(), requestedEvent(), createdEvent()]);
    await t.drain();
    await t.given([createdEvent()]);
    await t.drain();
    expect(_confirmed(t), hasLength(1));
  });

  // @requires a calendar event for a meeting that was never reserved
  // @ensures the refusal is ignored: no meeting_confirmed is recorded and the subscription does not fail
  test('a calendar event for a meeting outside pending_calendar records nothing', () async {
    final t = TestApp(slices: const [ConfirmBookedMeetingSlice()]);
    await t.start();

    await t.given([createdEvent(meetingId: 'meeting-zz')]);
    await t.drain();
    expect(_confirmed(t), isEmpty);
  });
}
