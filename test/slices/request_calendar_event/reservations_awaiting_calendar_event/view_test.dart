import 'package:em_calendly_example/slices/request_calendar_event/reservations_awaiting_calendar_event/view.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

void main() {
  final reserved = reservedEvent();

  // @requires a meeting_slot_reserved event and the booking_slot_verified event for the same meeting
  // @ensures scenario reservation_waits_for_its_calendar_event: the item is listed, verified, with its meeting data
  test('reservation_waits_for_its_calendar_event', () {
    final v = reservationsAwaitingCalendarEventView;
    final state = v.evolve(v.evolve(v.initialState, reserved), verifiedEvent());
    expect(state, isNotNull);
    expect(state!.verified, isTrue);
    expect(state.meetingId, reserved.meetingId);
    expect(state.hostId, reserved.hostId);
    expect(state.meetingTitle, reserved.meetingTitle);
    expect(state.meetingLocation, reserved.meetingLocation);
    expect(state.slotStart, reserved.slotStart);
    expect(state.slotEnd, reserved.slotEnd);
    expect(state.participants, reserved.participants);
  });

  // @requires a verified reservation followed by its calendar_event_requested event
  // @ensures scenario requested_reservation_leaves_the_list: the item leaves the list (the state is null)
  test('requested_reservation_leaves_the_list', () {
    final v = reservationsAwaitingCalendarEventView;
    final verified = v.evolve(v.evolve(v.initialState, reserved), verifiedEvent());
    expect(v.evolve(verified, requestedEvent()), isNull);
  });

  // @requires a meeting_slot_reserved event with no booking_slot_verified event
  // @ensures scenario unchecked_reservation_is_not_requested: the item is not verified, so it is not listed to request
  test('unchecked_reservation_is_not_requested', () {
    final v = reservationsAwaitingCalendarEventView;
    final state = v.evolve(v.initialState, reserved);
    expect(state, isNotNull);
    expect(state!.verified, isFalse);
  });

  // @requires a booking_slot_verified event for a meeting that has no reservation in the view
  // @ensures the verification opens no item: the state stays null
  test('a verification without a reservation opens no item', () {
    final v = reservationsAwaitingCalendarEventView;
    expect(v.evolve(v.initialState, verifiedEvent()), isNull);
  });

  // @requires the same meeting_slot_reserved event folded twice, and then the verification folded twice
  // @ensures folding a repeated event yields the same item (idempotent)
  test('repeated events yield the same item', () {
    final v = reservationsAwaitingCalendarEventView;
    final once = v.evolve(v.initialState, reserved);
    expect(v.evolve(once, reserved), equals(once));
    final verified = v.evolve(once, verifiedEvent());
    expect(v.evolve(verified, verifiedEvent()), equals(verified));
  });
}
