import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/verify_rescheduled_slot/module.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';
import 'fixtures.dart';

void main() {
  // @requires a meeting reserved, confirmed, rescheduled to a new slot, and the host's free answer for it
  // @ensures the answer records exactly one new_slot_verified for the meeting
  test('a free answer verifies the new slot once', () async {
    final t = TestApp(slices: const [VerifyRescheduledSlotSlice()]);
    await t.start();

    final reserved = reservedEvent();
    await t.given([reserved, confirmedEvent(), rescheduleRequestedEvent(), freeAnswer()]);
    await t.drain();
    final verified = t.events.all.where((e) => e.event is NewSlotVerifiedEvent);
    expect(verified, hasLength(1));
    expect((verified.single.event as NewSlotVerifiedEvent).meetingId, MeetingId('meeting-1'));

    await t.drain();
    expect(t.events.all.where((e) => e.event is NewSlotVerifiedEvent), hasLength(1));
  });

  // @requires a free answer for a meeting that is still pending_calendar, not rescheduling
  // @ensures the answer records nothing
  test('a free answer for a pending_calendar meeting records nothing', () async {
    final t = TestApp(slices: const [VerifyRescheduledSlotSlice()]);
    await t.start();

    await t.given([reservedEvent(), freeAnswer()]);
    await t.drain();
    expect(t.events.all.where((e) => e.event is NewSlotVerifiedEvent), isEmpty);
  });
}
