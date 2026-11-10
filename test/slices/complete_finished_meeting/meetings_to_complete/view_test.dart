import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/complete_finished_meeting/meetings_to_complete/view.dart';
import 'package:em_calendly_example/slices/complete_finished_meeting/meetings_to_complete/state.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

MeetingToComplete? _fold(List<MeetingsEvent> history) =>
    history.fold(meetingsToCompleteView.initialState, meetingsToCompleteView.evolve);

void main() {
  final reserved = reservedEvent();
  final confirmed = confirmedEvent();

  // @requires a meeting_slot_reserved event followed by a meeting_confirmed event
  // @ensures scenario ended_meeting_is_completed: the item is due with the reserved end (the processor completes it)
  test('ended_meeting_is_completed', () {
    final item = _fold([reserved, confirmed]);
    expect(item, isNotNull);
    expect(item!.confirmed, isTrue);
    expect(item.slotEnd.value, meetingEnd);
  });

  // @requires a meeting_slot_reserved event followed by a meeting_confirmed event
  // @ensures scenario confirmed_meeting_waits_for_its_end: the item is listed with the meeting and its end
  test('confirmed_meeting_waits_for_its_end', () {
    final item = _fold([reserved, confirmed]);
    expect(
      item,
      MeetingToComplete(meetingId: MeetingId('meeting-1'), slotEnd: SlotEnd(meetingEnd), confirmed: true),
    );
  });

  // @requires a meeting_slot_reserved event, then meeting_confirmed, then meeting_canceled
  // @ensures scenario canceled_meeting_leaves_the_list: the item leaves the list (the state is null)
  test('canceled_meeting_leaves_the_list', () {
    expect(_fold([reserved, confirmed, canceledEvent()]), isNull);
  });

  // @requires a meeting_slot_reserved event, then meeting_confirmed, then meeting_completed
  // @ensures scenario completed_meeting_leaves_the_list: the item leaves the list (the state is null)
  test('completed_meeting_leaves_the_list', () {
    expect(_fold([reserved, confirmed, completedEvent()]), isNull);
  });

  // @requires a confirmed meeting that is moved directly in the calendar to a later end
  // @ensures scenario directly_moved_meeting_waits_for_its_new_end: the item takes the new end and stays confirmed
  test('directly_moved_meeting_waits_for_its_new_end', () {
    final newEnd = meetingEnd.add(const Duration(hours: 1));
    final item = _fold([reserved, confirmed, movedInCalendarEvent(newSlotEnd: newEnd)]);
    expect(item!.slotEnd.value, newEnd);
    expect(item.confirmed, isTrue);
  });

  // @requires a confirmed meeting whose reschedule is requested, then completed
  // @ensures scenario rescheduled_meeting_takes_the_new_end: the request waits; the completed reschedule moves the end
  test('a reschedule takes the new end', () {
    final originalEnd = meetingEnd;
    final newEnd = meetingEnd.add(const Duration(hours: 2));
    final requested = _fold([reserved, confirmed, rescheduleRequestedEvent(newSlotEnd: newEnd)]);
    expect(requested!.slotEnd.value, originalEnd);
    expect(requested.pendingSlotEnd?.value, newEnd);

    final rescheduled = _fold([reserved, confirmed, rescheduleRequestedEvent(newSlotEnd: newEnd), rescheduledEvent()]);
    expect(rescheduled!.slotEnd.value, newEnd);
    expect(rescheduled.pendingSlotEnd, isNull);
  });

  // @requires a confirmed meeting whose reschedule to a later end is requested, then fails
  // @ensures scenario failed_reschedule_keeps_the_original_end: the item keeps its original end and drops the request
  test('a failed reschedule keeps the original end', () {
    final newEnd = meetingEnd.add(const Duration(hours: 2));
    final failed = _fold([reserved, confirmed, rescheduleRequestedEvent(newSlotEnd: newEnd), rescheduleFailedEvent()]);
    expect(failed!.slotEnd.value, meetingEnd);
    expect(failed.pendingSlotEnd, isNull);
    expect(failed.confirmed, isTrue);
  });

  // @requires a confirmed meeting with a pending reschedule, then moved directly in the calendar
  // @ensures the direct move sets the end and drops the pending reschedule
  test('a direct move drops a pending reschedule', () {
    final requestedEnd = meetingEnd.add(const Duration(hours: 2));
    final movedEnd = meetingEnd.add(const Duration(hours: 1));
    final item = _fold([
      reserved,
      confirmed,
      rescheduleRequestedEvent(newSlotEnd: requestedEnd),
      movedInCalendarEvent(newSlotEnd: movedEnd),
    ]);
    expect(item!.slotEnd.value, movedEnd);
    expect(item.pendingSlotEnd, isNull);
  });

  // @requires a meeting_slot_reserved event that is redelivered after the meeting is confirmed
  // @ensures the redelivery keeps the confirmed item: a repeated reservation does not unconfirm it
  test('a repeated reservation keeps a confirmed item', () {
    expect(_fold([reserved, confirmed, reserved]), _fold([reserved, confirmed]));
  });

  // @requires a meeting_slot_reserved event with no confirmation
  // @ensures the item is open but not confirmed, so it is not due
  test('an unconfirmed reservation is not confirmed', () {
    expect(_fold([reserved])!.confirmed, isFalse);
  });

  // @requires any history of one meeting: reserved, confirmed, then a direct move
  // @ensures folding a repeated event yields the same result (idempotent)
  test('repeated events yield the same result', () {
    final moved = movedInCalendarEvent(newSlotEnd: meetingEnd.add(const Duration(hours: 1)));
    final once = _fold([reserved, confirmed, moved]);
    expect(meetingsToCompleteView.evolve(once, moved), equals(once));
    expect(
      meetingsToCompleteView.evolve(meetingsToCompleteView.evolve(once, completedEvent()), completedEvent()),
      isNull,
    );
  });

  // @requires a meeting_canceled or meeting_completed event with no open item
  // @ensures the closing event opens no item: the state stays null
  test('a closing event without an item opens no item', () {
    expect(meetingsToCompleteView.evolve(meetingsToCompleteView.initialState, canceledEvent()), isNull);
    expect(meetingsToCompleteView.evolve(meetingsToCompleteView.initialState, completedEvent()), isNull);
  });
}
