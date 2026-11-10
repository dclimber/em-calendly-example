import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/request_calendar_event/module.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';
import 'fixtures.dart';

void main() {
  // @requires a meeting_slot_reserved and a booking_slot_verified event, and the slice running alone
  // @ensures the verified reservation requests exactly one calendar event, and the item leaves the to-do list
  test('a verified reservation requests one calendar event', () async {
    final t = TestApp(slices: const [RequestCalendarEventSlice()]);
    await t.start();

    final reserved = reservedEvent();
    await t.given([reserved, verifiedEvent()]);
    await t.drain();
    expect(t.events.all.where((e) => e.event is CalendarEventRequestedEvent), hasLength(1));
    expect(await t.views.get('reservations_awaiting_calendar_event', reserved.meetingId.value), isNull);
  });

  // @requires a reservation that is not verified yet
  // @ensures the slice requests nothing until the booking_slot_verified event arrives
  test('an unverified reservation requests nothing', () async {
    final t = TestApp(slices: const [RequestCalendarEventSlice()]);
    await t.start();

    await t.given([reservedEvent()]);
    await t.drain();
    expect(t.events.all.where((e) => e.event is CalendarEventRequestedEvent), isEmpty);
  });

  // @requires a meeting whose calendar event was already requested, and the same reservation and verification
  // delivered again
  // @ensures the redelivery requests nothing more: still one calendar_event_requested
  test('a redelivered reservation requests nothing more', () async {
    final t = TestApp(slices: const [RequestCalendarEventSlice()]);
    await t.start();

    final reserved = reservedEvent();
    await t.given([reserved, verifiedEvent()]);
    await t.drain();
    await t.given([reserved, verifiedEvent()]);
    await t.drain();
    expect(t.events.all.where((e) => e.event is CalendarEventRequestedEvent), hasLength(1));
  });
}
