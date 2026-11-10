import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/request_calendar_event_update/reschedules_awaiting_calendar_update/view.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

void main() {
  final requested = rescheduleRequestedEvent();

  // @requires a meeting_reschedule_requested and the new_slot_verified event for the same meeting
  // @ensures scenario reschedule_waits_for_its_update: the item is listed and verified, with its new slot
  test('reschedule_waits_for_its_update', () {
    final v = reschedulesAwaitingCalendarUpdateView;
    final state = v.evolve(v.evolve(v.initialState, requested), newSlotVerifiedEvent());
    expect(state, isNotNull);
    expect(state!.verified, isTrue);
    expect(state.meetingId, requested.meetingId);
    expect(state.newSlotStart, requested.newSlotStart);
    expect(state.newSlotEnd, requested.newSlotEnd);
    expect(state.calendarEventId, requested.calendarEventId);
  });

  // @requires a verified reschedule followed by its calendar_event_update_requested event
  // @ensures scenario requested_update_leaves_the_list: the item leaves the list (the state is null)
  test('requested_update_leaves_the_list', () {
    final v = reschedulesAwaitingCalendarUpdateView;
    final verified = v.evolve(v.evolve(v.initialState, requested), newSlotVerifiedEvent());
    expect(v.evolve(verified, updateRequestedEvent()), isNull);
  });

  // @requires a meeting_reschedule_requested event with no new_slot_verified event
  // @ensures scenario unchecked_reschedule_is_not_requested: the item is not verified, so it is not listed to request
  test('unchecked_reschedule_is_not_requested', () {
    final v = reschedulesAwaitingCalendarUpdateView;
    final state = v.evolve(v.initialState, requested);
    expect(state, isNotNull);
    expect(state!.verified, isFalse);
  });

  // @requires a verified reschedule and a meeting_moved_in_calendar event for the same meeting
  // @ensures scenario direct_move_stops_the_update: the item leaves the list (the state is null)
  test('direct_move_stops_the_update', () {
    final v = reschedulesAwaitingCalendarUpdateView;
    final verified = v.evolve(v.evolve(v.initialState, requested), newSlotVerifiedEvent());
    final moved = MeetingMovedInCalendarEvent(
      meetingId: requested.meetingId,
      newSlotStart: NewSlotStart(DateTime.utc(2027, 3, 17, 10)),
      newSlotEnd: NewSlotEnd(DateTime.utc(2027, 3, 17, 10, 30)),
    );
    expect(v.evolve(verified, moved), isNull);
  });

  // @requires a verified reschedule and a meeting_canceled event for the same meeting
  // @ensures scenario direct_deletion_stops_the_update: the item leaves the list (the state is null)
  test('direct_deletion_stops_the_update', () {
    final v = reschedulesAwaitingCalendarUpdateView;
    final verified = v.evolve(v.evolve(v.initialState, requested), newSlotVerifiedEvent());
    expect(v.evolve(verified, MeetingCanceledEvent(meetingId: requested.meetingId)), isNull);
  });

  // @requires a new_slot_verified event for a meeting that has no reschedule in the view
  // @ensures the verification opens no item: the state stays null
  test('a verification without a reschedule opens no item', () {
    final v = reschedulesAwaitingCalendarUpdateView;
    expect(v.evolve(v.initialState, newSlotVerifiedEvent()), isNull);
  });

  // @requires the same meeting_reschedule_requested folded twice, and then the verification folded twice
  // @ensures folding a repeated event yields the same item (idempotent), and a redelivered request keeps its verification
  test('repeated events yield the same item', () {
    final v = reschedulesAwaitingCalendarUpdateView;
    final once = v.evolve(v.initialState, requested);
    expect(v.evolve(once, requested), equals(once));
    final verified = v.evolve(once, newSlotVerifiedEvent());
    expect(v.evolve(verified, newSlotVerifiedEvent()), equals(verified));
    expect(v.evolve(verified, requested), equals(verified));
  });
}
