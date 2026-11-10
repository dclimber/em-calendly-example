import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/request_booking_availability_check/reservations_awaiting_live_check/view.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

void main() {
  final reserved = reservedEvent();

  // @requires a meeting_slot_reserved event
  // @ensures scenario held_slot_waits_for_its_check: the held slot is listed with its meeting, host, and slot
  test('held_slot_waits_for_its_check', () {
    final state = reservationsAwaitingLiveCheckView.evolve(reservationsAwaitingLiveCheckView.initialState, reserved);
    expect(state, isNotNull);
    expect(state!.meetingId, reserved.meetingId);
    expect(state.hostId, reserved.hostId);
    expect(state.slotStart, reserved.slotStart);
    expect(state.slotEnd, reserved.slotEnd);
  });

  // @requires a held slot followed by its booking_availability_check_requested event
  // @ensures scenario requested_check_leaves_the_list: the item leaves the list (the state is null)
  test('requested_check_leaves_the_list', () {
    final v = reservationsAwaitingLiveCheckView;
    final listed = v.evolve(v.initialState, reserved);
    final requested = BookingAvailabilityCheckRequestedEvent(
      meetingId: reserved.meetingId,
      hostId: reserved.hostId,
      slotStart: reserved.slotStart,
      slotEnd: reserved.slotEnd,
    );
    expect(v.evolve(listed, requested), isNull);
  });

  // @requires the same meeting_slot_reserved event folded twice
  // @ensures folding a repeated reservation yields the same item (idempotent)
  test('repeated reservation yields the same item', () {
    final v = reservationsAwaitingLiveCheckView;
    final once = v.evolve(v.initialState, reserved);
    expect(v.evolve(once, reserved), equals(once));
  });
}
