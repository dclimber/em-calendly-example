import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/complete_meeting_cancellation/module.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';
import 'fixtures.dart';

List<MeetingCanceledEvent> _canceled(TestApp t) =>
    t.events.all.map((e) => e.event).whereType<MeetingCanceledEvent>().toList();

void main() {
  // @requires a meeting in canceling, then the calendar event deleted for it
  // @ensures the application records exactly one meeting_canceled for the meeting
  test('deleted calendar event cancels the meeting once', () async {
    final t = TestApp(slices: const [CompleteMeetingCancellationSlice()]);
    await t.start();

    await t.given([
      reservedEvent(),
      confirmedEvent(),
      cancellationRequestedEvent(),
      deletionRequestedEvent(),
      calendarEventDeleted(),
    ]);
    await t.drain();
    final canceled = _canceled(t);
    expect(canceled, hasLength(1));
    expect(canceled.single.meetingId, MeetingId('meeting-1'));

    await t.drain();
    expect(_canceled(t), hasLength(1));
  });

  // @requires a meeting whose cancellation completed, then the same calendar event delivered again
  // @ensures the redelivery adds nothing: still one meeting_canceled
  test('a redelivered calendar event adds nothing', () async {
    final t = TestApp(slices: const [CompleteMeetingCancellationSlice()]);
    await t.start();

    await t.given([reservedEvent(), confirmedEvent(), cancellationRequestedEvent(), calendarEventDeleted()]);
    await t.drain();
    await t.given([calendarEventDeleted()]);
    await t.drain();
    expect(_canceled(t), hasLength(1));
  });

  // @requires a calendar event for a meeting that is not canceling
  // @ensures the refusal is ignored: no meeting_canceled is recorded and the subscription does not fail
  test('a calendar event for a meeting outside canceling records nothing', () async {
    final t = TestApp(slices: const [CompleteMeetingCancellationSlice()]);
    await t.start();

    await t.given([reservedEvent(meetingId: 'meeting-zz'), calendarEventDeleted(meetingId: 'meeting-zz')]);
    await t.drain();
    expect(_canceled(t), isEmpty);
  });
}
