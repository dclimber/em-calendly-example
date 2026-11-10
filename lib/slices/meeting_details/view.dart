import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/meetings/api.dart';
import 'state.dart';

/// The pure view of `meeting_details`, one document per meeting.
///
/// `meeting_slot_reserved` creates the document, not yet confirmed (no status). `meeting_confirmed` makes it active.
/// A reschedule or cancellation request puts it in change in progress, and its outcome decides the status: a completed
/// reschedule or a direct calendar move gives the new slot and active; a failed change gives active with the failure
/// reason; a completed cancellation gives canceled; a completed meeting gives completed. Events of a meeting that is
/// not confirmed change nothing, and a canceled or completed meeting stays that way.
final meetingDetailsView = View<MeetingDetails?, MeetingsEvent>(
  initialState: null,
  evolve: (state, event) => switch (event) {
    MeetingSlotReservedEvent(
      :final meetingId,
      :final meetingTypeId,
      :final meetingTitle,
      :final meetingLocation,
      :final slotStart,
      :final slotEnd,
      :final participants,
    ) =>
      MeetingDetails(
        meetingId: meetingId,
        meetingTypeId: meetingTypeId,
        meetingTitle: meetingTitle,
        meetingLocation: meetingLocation,
        slotStart: slotStart,
        slotEnd: slotEnd,
        participants: participants,
      ),
    MeetingConfirmedEvent(:final calendarEventId) when state != null => state.copyWith(
      status: MeetingDetailsStatus.active,
      calendarEventId: calendarEventId,
    ),
    MeetingRescheduleRequestedEvent(:final newSlotStart, :final newSlotEnd, :final calendarEventId)
        when state != null && state.canChange =>
      state.copyWith(
        status: MeetingDetailsStatus.changeInProgress,
        requestedSlotStart: SlotStart(newSlotStart.value),
        requestedSlotEnd: SlotEnd(newSlotEnd.value),
        calendarEventId: calendarEventId,
        clearFailureReason: true,
      ),
    MeetingRescheduledEvent() when state != null && state.status == MeetingDetailsStatus.changeInProgress =>
      state.copyWith(
        status: MeetingDetailsStatus.active,
        slotStart: state.requestedSlotStart,
        slotEnd: state.requestedSlotEnd,
        clearRequestedSlot: true,
        clearFailureReason: true,
      ),
    MeetingRescheduleFailedEvent(:final failureReason)
        when state != null && state.status == MeetingDetailsStatus.changeInProgress =>
      state.copyWith(status: MeetingDetailsStatus.active, failureReason: failureReason, clearRequestedSlot: true),
    MeetingMovedInCalendarEvent(:final newSlotStart, :final newSlotEnd) when state != null && state.isLive =>
      state.copyWith(
        status: MeetingDetailsStatus.active,
        slotStart: SlotStart(newSlotStart.value),
        slotEnd: SlotEnd(newSlotEnd.value),
        clearRequestedSlot: true,
        clearFailureReason: true,
      ),
    MeetingCancellationRequestedEvent(:final calendarEventId) when state != null && state.canChange => state.copyWith(
      status: MeetingDetailsStatus.changeInProgress,
      calendarEventId: calendarEventId,
      clearFailureReason: true,
    ),
    MeetingCancellationFailedEvent(:final failureReason)
        when state != null && state.status == MeetingDetailsStatus.changeInProgress =>
      state.copyWith(status: MeetingDetailsStatus.active, failureReason: failureReason),
    MeetingCanceledEvent() when state != null && state.isLive => state.copyWith(
      status: MeetingDetailsStatus.canceled,
      clearFailureReason: true,
    ),
    MeetingCompletedEvent() when state != null && state.isLive => state.copyWith(
      status: MeetingDetailsStatus.completed,
      clearFailureReason: true,
    ),
    _ => state,
  },
);
