import 'package:em_calendly_example/slices/send_booking_confirmation/confirmations_to_send/view.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

void main() {
  final reserved = reservedEvent();

  // @requires a meeting_slot_reserved event and then its meeting_confirmed event
  // @ensures scenario confirmed_meeting_waits_for_announcement: the item is listed and ready, with its meeting data
  test('confirmed_meeting_waits_for_announcement', () {
    final v = confirmationsToSendView;
    final state = v.evolve(v.evolve(v.initialState, reserved), confirmedEvent());
    expect(state, isNotNull);
    expect(state!.ready, isTrue);
    expect(state.meetingId, reserved.meetingId);
    expect(state.meetingTitle, reserved.meetingTitle);
    expect(state.meetingLocation, reserved.meetingLocation);
    expect(state.slotStart, reserved.slotStart);
    expect(state.slotEnd, reserved.slotEnd);
    expect(state.participants, reserved.participants);
  });

  // @requires a meeting_slot_reserved event with no meeting_confirmed event
  // @ensures scenario reservation_alone_is_not_announced: the item is kept but not ready, so it is not listed to send
  test('reservation_alone_is_not_announced', () {
    final v = confirmationsToSendView;
    final state = v.evolve(v.initialState, reserved);
    expect(state, isNotNull);
    expect(state!.ready, isFalse);
  });

  // @requires a confirmed meeting followed by its booking_confirmation_sent event
  // @ensures scenario announced_meeting_leaves_the_list: the item leaves the list (the state is null)
  test('announced_meeting_leaves_the_list', () {
    final v = confirmationsToSendView;
    final ready = v.evolve(v.evolve(v.initialState, reserved), confirmedEvent());
    expect(v.evolve(ready, sentEvent()), isNull);
  });

  // @requires a meeting_confirmed event for a meeting that has no reservation in the view
  // @ensures the confirmation opens no item: the state stays null
  test('a confirmation without a reservation opens no item', () {
    final v = confirmationsToSendView;
    expect(v.evolve(v.initialState, confirmedEvent()), isNull);
  });

  // @requires a confirmed meeting whose reservation is delivered again
  // @ensures the redelivered reservation keeps the ready flag: a redelivery never unmakes an announcement
  test('a redelivered reservation keeps the item ready', () {
    final v = confirmationsToSendView;
    final ready = v.evolve(v.evolve(v.initialState, reserved), confirmedEvent());
    expect(v.evolve(ready, reserved), equals(ready));
  });

  // @requires the same meeting_slot_reserved and meeting_confirmed events folded twice
  // @ensures folding a repeated event yields the same item (idempotent)
  test('repeated events yield the same item', () {
    final v = confirmationsToSendView;
    final once = v.evolve(v.initialState, reserved);
    expect(v.evolve(once, reserved), equals(once));
    final ready = v.evolve(once, confirmedEvent());
    expect(v.evolve(ready, confirmedEvent()), equals(ready));
  });
}
