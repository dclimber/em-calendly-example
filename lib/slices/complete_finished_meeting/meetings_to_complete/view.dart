import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'state.dart';

/// The pure view `meetings_to_complete`, one item per meeting. `meeting_slot_reserved` opens the item, unconfirmed.
/// `meeting_confirmed` makes it due. A direct calendar move takes its new end. A reschedule request only sets a pending
/// end; `meeting_rescheduled` moves that pending end into the item, and `meeting_reschedule_failed` drops it, so a
/// failed reschedule never changes the end. `meeting_canceled` and `meeting_completed` remove the item. A repeated
/// reservation keeps the item as it is, so that a redelivered event cannot unconfirm a meeting.
final meetingsToCompleteView = View<MeetingToComplete?, MeetingsEvent>(
  initialState: null,
  evolve: (state, event) => switch (event) {
    MeetingSlotReservedEvent(:final meetingId, :final slotEnd) =>
      state ?? MeetingToComplete(meetingId: meetingId, slotEnd: slotEnd, confirmed: false),
    MeetingConfirmedEvent() => state?.copyWith(confirmed: true),
    MeetingRescheduleRequestedEvent(:final newSlotEnd) => state?.copyWith(pendingSlotEnd: SlotEnd(newSlotEnd.value)),
    MeetingRescheduledEvent() => _completePendingReschedule(state),
    MeetingRescheduleFailedEvent() => state?.copyWith(clearPendingSlotEnd: true),
    MeetingMovedInCalendarEvent(:final newSlotEnd) => state?.copyWith(
      slotEnd: SlotEnd(newSlotEnd.value),
      clearPendingSlotEnd: true,
    ),
    MeetingCanceledEvent() => null,
    MeetingCompletedEvent() => null,
    _ => state,
  },
);

MeetingToComplete? _completePendingReschedule(MeetingToComplete? state) {
  final pending = state?.pendingSlotEnd;
  if (state == null || pending == null) return state;
  return state.copyWith(slotEnd: pending, clearPendingSlotEnd: true);
}
