import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/send_booking_confirmation/module.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';
import 'fixtures.dart';

void main() {
  // @requires a meeting_slot_reserved and a meeting_confirmed event, and the slice running alone
  // @ensures the confirmed meeting sends exactly one email to both participants, and the item leaves the to-do list
  test('a confirmed meeting sends one email to both participants', () async {
    final t = TestApp(slices: const [SendBookingConfirmationSlice()]);
    await t.start();

    final reserved = reservedEvent();
    await t.given([reserved, confirmedEvent()]);
    await t.drain();
    expect(t.mailer.sent, hasLength(1));
    expect(t.mailer.sent.single.to, ['alice@example.com', 'bob@example.com']);
    expect(t.mailer.sent.single.subject, 'Meeting confirmed: Intro call');
    expect(t.events.all.where((e) => e.event is BookingConfirmationSentEvent), hasLength(1));
    expect(await t.views.get('confirmations_to_send', reserved.meetingId.value), isNull);
  });

  // @requires a meeting that is reserved but not confirmed
  // @ensures the slice sends nothing until the meeting_confirmed event arrives
  test('an unconfirmed meeting sends nothing', () async {
    final t = TestApp(slices: const [SendBookingConfirmationSlice()]);
    await t.start();

    await t.given([reservedEvent()]);
    await t.drain();
    expect(t.mailer.sent, isEmpty);
    expect(t.events.all.where((e) => e.event is BookingConfirmationSentEvent), isEmpty);
  });

  // @requires a meeting whose confirmation was already sent, and its meeting_confirmed event delivered again
  // @ensures the redelivery sends no second email and records no second booking_confirmation_sent
  test('a redelivered confirmation sends nothing more', () async {
    final t = TestApp(slices: const [SendBookingConfirmationSlice()]);
    await t.start();

    final reserved = reservedEvent();
    await t.given([reserved, confirmedEvent()]);
    await t.drain();
    await t.drain();
    await t.given([confirmedEvent()]);
    await t.drain();
    expect(t.mailer.sent, hasLength(1));
    expect(t.events.all.where((e) => e.event is BookingConfirmationSentEvent), hasLength(1));
  });
}
