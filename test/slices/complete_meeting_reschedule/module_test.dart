import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/complete_meeting_reschedule/module.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';
import 'fixtures.dart';

List<MeetingRescheduledEvent> _rescheduled(TestApp t) =>
    t.events.all.map((e) => e.event).whereType<MeetingRescheduledEvent>().toList();

void main() {
  // @requires a meeting in rescheduling, then the calendar event moved for it
  // @ensures the application records exactly one meeting_rescheduled for the meeting
  test('moved calendar event completes the reschedule once', () async {
    final t = TestApp(slices: const [CompleteMeetingRescheduleSlice()]);
    await t.start();

    await t.given([reservedEvent(), confirmedEvent(), rescheduleRequestedEvent(), calendarEventUpdated()]);
    await t.drain();
    final rescheduled = _rescheduled(t);
    expect(rescheduled, hasLength(1));
    expect(rescheduled.single.meetingId, MeetingId('meeting-1'));

    await t.drain();
    expect(_rescheduled(t), hasLength(1));
  });

  // @requires a meeting whose reschedule completed, then the same calendar event delivered again
  // @ensures the redelivery adds nothing: still one meeting_rescheduled
  test('a redelivered calendar event adds nothing', () async {
    final t = TestApp(slices: const [CompleteMeetingRescheduleSlice()]);
    await t.start();

    await t.given([reservedEvent(), confirmedEvent(), rescheduleRequestedEvent(), calendarEventUpdated()]);
    await t.drain();
    await t.given([calendarEventUpdated()]);
    await t.drain();
    expect(_rescheduled(t), hasLength(1));
  });

  // @requires a calendar event for a meeting that is not rescheduling
  // @ensures the refusal is ignored: no meeting_rescheduled is recorded and the subscription does not fail
  test('a calendar event for a meeting outside rescheduling records nothing', () async {
    final t = TestApp(slices: const [CompleteMeetingRescheduleSlice()]);
    await t.start();

    await t.given([reservedEvent(meetingId: 'meeting-zz'), calendarEventUpdated(meetingId: 'meeting-zz')]);
    await t.drain();
    expect(_rescheduled(t), isEmpty);
  });
}
