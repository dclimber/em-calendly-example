import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/verify_booked_slot/module.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';
import 'fixtures.dart';

void main() {
  // @requires a meeting reserved and still pending_calendar, and its host's free answer
  // @ensures the answer records exactly one booking_slot_verified for the meeting
  test('a free answer verifies the booked slot once', () async {
    final t = TestApp(slices: const [VerifyBookedSlotSlice()]);
    await t.start();

    await t.given([reservedEvent(), freeAnswer()]);
    await t.drain();
    final verified = t.events.all.where((e) => e.event is BookingSlotVerifiedEvent);
    expect(verified, hasLength(1));
    expect((verified.single.event as BookingSlotVerifiedEvent).meetingId, MeetingId('meeting-1'));

    await t.drain();
    expect(t.events.all.where((e) => e.event is BookingSlotVerifiedEvent), hasLength(1));
  });

  // @requires the same free answer delivered again after the slot was verified
  // @ensures the redelivery adds nothing: still one booking_slot_verified
  test('a redelivered free answer adds nothing', () async {
    final t = TestApp(slices: const [VerifyBookedSlotSlice()]);
    await t.start();

    await t.given([reservedEvent(), freeAnswer()]);
    await t.drain();
    await t.given([freeAnswer()]);
    await t.drain();
    expect(t.events.all.where((e) => e.event is BookingSlotVerifiedEvent), hasLength(1));
  });

  // @requires a meeting already confirmed, and a free answer for it
  // @ensures the answer records nothing, since the meeting is no longer pending_calendar
  test('a free answer for a confirmed meeting records nothing', () async {
    final t = TestApp(slices: const [VerifyBookedSlotSlice()]);
    await t.start();

    final reserved = reservedEvent();
    await t.given([
      reserved,
      MeetingConfirmedEvent(meetingId: reserved.meetingId, calendarEventId: CalendarEventId('cal-1')),
      freeAnswer(),
    ]);
    await t.drain();
    expect(t.events.all.where((e) => e.event is BookingSlotVerifiedEvent), isEmpty);
  });
}
