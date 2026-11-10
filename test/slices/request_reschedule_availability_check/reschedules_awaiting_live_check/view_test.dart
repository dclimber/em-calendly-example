import 'package:em_calendly_example/slices/request_reschedule_availability_check/reschedules_awaiting_live_check/view.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

void main() {
  final requested = rescheduleRequestedEvent();

  // @requires a meeting_reschedule_requested event
  // @ensures scenario held_slot_waits_for_its_check: the requested new time is listed with its meeting, host, and slot
  test('held_slot_waits_for_its_check', () {
    final v = reschedulesAwaitingLiveCheckView;
    final state = v.evolve(v.initialState, requested);
    expect(state, isNotNull);
    expect(state!.meetingId, requested.meetingId);
    expect(state.hostId, requested.hostId);
    expect(state.newSlotStart, requested.newSlotStart);
    expect(state.newSlotEnd, requested.newSlotEnd);
  });

  // @requires a requested new time followed by its reschedule_availability_check_requested event
  // @ensures scenario requested_check_leaves_the_list: the item leaves the list (the state is null)
  test('requested_check_leaves_the_list', () {
    final v = reschedulesAwaitingLiveCheckView;
    final listed = v.evolve(v.initialState, requested);
    expect(v.evolve(listed, checkRequestedFor(requested)), isNull);
  });

  // @requires a requested new time followed by a direct move in the calendar
  // @ensures scenario direct_move_stops_the_check: the item leaves the list (the state is null)
  test('direct_move_stops_the_check', () {
    final v = reschedulesAwaitingLiveCheckView;
    final listed = v.evolve(v.initialState, requested);
    expect(v.evolve(listed, movedInCalendarEvent()), isNull);
  });

  // @requires a requested new time followed by a direct deletion of the meeting
  // @ensures scenario direct_deletion_stops_the_check: the item leaves the list (the state is null)
  test('direct_deletion_stops_the_check', () {
    final v = reschedulesAwaitingLiveCheckView;
    final listed = v.evolve(v.initialState, requested);
    expect(v.evolve(listed, canceledEvent()), isNull);
  });

  // @requires the same meeting_reschedule_requested event folded twice
  // @ensures folding a repeated request yields the same item (idempotent)
  test('repeated request yields the same item', () {
    final v = reschedulesAwaitingLiveCheckView;
    final once = v.evolve(v.initialState, requested);
    expect(v.evolve(once, requested), equals(once));
  });
}
