import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/request_booking_availability_check/module.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';
import 'fixtures.dart';

void main() {
  // @requires a meeting_slot_reserved event and the slice running alone
  // @ensures the reservation requests exactly one live check, and the item leaves the to-do list
  test('a held slot requests one live check', () async {
    final t = TestApp(slices: const [RequestBookingAvailabilityCheckSlice()]);
    await t.start();

    final reserved = reservedEvent();
    await t.given([reserved]);
    await t.drain();
    expect(t.events.all.where((e) => e.event is BookingAvailabilityCheckRequestedEvent), hasLength(1));
    expect(await t.views.get('reservations_awaiting_live_check', reserved.meetingId.value), isNull);

    await t.drain();
    expect(t.events.all.where((e) => e.event is BookingAvailabilityCheckRequestedEvent), hasLength(1));
  });

  // @requires a meeting whose live check was already requested, and the same reservation delivered again
  // @ensures the repeated reservation requests nothing more: still one booking_availability_check_requested
  test('a repeated reservation requests nothing more', () async {
    final t = TestApp(slices: const [RequestBookingAvailabilityCheckSlice()]);
    await t.start();

    final reserved = reservedEvent();
    await t.given([reserved]);
    await t.drain();
    await t.given([reserved]);
    await t.drain();
    expect(t.events.all.where((e) => e.event is BookingAvailabilityCheckRequestedEvent), hasLength(1));
  });
}
