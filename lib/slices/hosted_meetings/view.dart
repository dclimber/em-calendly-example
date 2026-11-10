import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/meetings/api.dart';
import 'state.dart';

/// The pure view of `hosted_meetings`, one document per meeting. `meeting_slot_reserved` creates the document, not yet
/// listed. `meeting_confirmed` makes it active. A reschedule request holds its slot, and the completed reschedule takes
/// it. A direct calendar move takes its slot at once. `meeting_canceled` and `meeting_completed` end a confirmed
/// meeting. Events that arrive before the reservation change nothing.
final hostedMeetingsView = View<HostedMeeting?, MeetingsEvent>(
  initialState: null,
  evolve: (state, event) => switch (event) {
    MeetingSlotReservedEvent(
      :final meetingId,
      :final hostId,
      :final meetingTitle,
      :final slotStart,
      :final slotEnd,
      :final participants,
    ) =>
      HostedMeeting(
        meetingId: meetingId,
        hostId: hostId,
        meetingTitle: meetingTitle,
        slotStart: slotStart,
        slotEnd: slotEnd,
        participants: participants,
      ),
    MeetingConfirmedEvent() => state?.confirmed(),
    MeetingRescheduleRequestedEvent(:final newSlotStart, :final newSlotEnd) => state?.withRequestedSlot(
      SlotStart(newSlotStart.value),
      SlotEnd(newSlotEnd.value),
    ),
    MeetingRescheduledEvent() => state?.rescheduled(),
    MeetingMovedInCalendarEvent(:final newSlotStart, :final newSlotEnd) => state?.movedTo(
      SlotStart(newSlotStart.value),
      SlotEnd(newSlotEnd.value),
    ),
    MeetingCanceledEvent() => state?.ended(HostedMeetingStatus.canceled),
    MeetingCompletedEvent() => state?.ended(HostedMeetingStatus.completed),
    _ => state,
  },
);
