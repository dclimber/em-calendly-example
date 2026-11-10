import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'state.dart';

/// The pure view `meetings_to_complete`, one item per meeting. `meeting_slot_reserved` opens the item, unconfirmed.
/// `meeting_confirmed` makes it due. A reschedule request and a direct calendar move take their new end; the completed
/// reschedule keeps it. `meeting_canceled` and `meeting_completed` remove the item. A repeated reservation keeps the
/// item as it is, so that a redelivered event cannot unconfirm a meeting.
final meetingsToCompleteView = View<MeetingToComplete?, MeetingsEvent>(
  initialState: null,
  evolve: (state, event) => switch (event) {
    MeetingSlotReservedEvent(:final meetingId, :final slotEnd) =>
      state ?? MeetingToComplete(meetingId: meetingId, slotEnd: slotEnd, confirmed: false),
    MeetingConfirmedEvent() => state?.copyWith(confirmed: true),
    MeetingRescheduleRequestedEvent(:final newSlotEnd) => state?.copyWith(slotEnd: SlotEnd(newSlotEnd.value)),
    MeetingRescheduledEvent() => state,
    MeetingMovedInCalendarEvent(:final newSlotEnd) => state?.copyWith(slotEnd: SlotEnd(newSlotEnd.value)),
    MeetingCanceledEvent() => null,
    MeetingCompletedEvent() => null,
    _ => state,
  },
);
