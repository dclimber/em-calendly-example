import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'state.dart';

/// The pure view `reschedule_notices_to_send`. A reservation records the title, the participants, and the booked slot.
/// A reschedule request records the new slot (not ready). `meeting_rescheduled` and `meeting_moved_in_calendar` make
/// the item ready, and `reschedule_notice_sent` clears the ready flag. A null state deletes nothing: the item is kept.
final rescheduleNoticesToSendView = View<RescheduleNoticeToSendState?, MeetingsEvent>(
  initialState: null,
  evolve: (state, event) => switch (event) {
    MeetingSlotReservedEvent() =>
      state == null
          ? RescheduleNoticeToSendState(
              meetingId: event.meetingId,
              meetingTitle: event.meetingTitle,
              newSlotStart: NewSlotStart(event.slotStart.value),
              newSlotEnd: NewSlotEnd(event.slotEnd.value),
              participants: event.participants,
            )
          : state.copyWith(meetingTitle: event.meetingTitle, participants: event.participants),
    MeetingRescheduleRequestedEvent() => _withNewSlot(
      state,
      meetingId: event.meetingId,
      newSlotStart: event.newSlotStart,
      newSlotEnd: event.newSlotEnd,
      participants: event.participants,
      ready: false,
    ),
    MeetingMovedInCalendarEvent() => _withNewSlot(
      state,
      meetingId: event.meetingId,
      newSlotStart: event.newSlotStart,
      newSlotEnd: event.newSlotEnd,
      participants: state?.participants ?? const Participants.empty(),
      ready: true,
    ),
    MeetingRescheduledEvent() => state?.copyWith(ready: true),
    RescheduleNoticeSentEvent() => state?.copyWith(ready: false),
    _ => state,
  },
);

RescheduleNoticeToSendState _withNewSlot(
  RescheduleNoticeToSendState? state, {
  required MeetingId meetingId,
  required NewSlotStart newSlotStart,
  required NewSlotEnd newSlotEnd,
  required Participants participants,
  required bool ready,
}) {
  if (state == null) {
    return RescheduleNoticeToSendState(
      meetingId: meetingId,
      meetingTitle: null,
      newSlotStart: newSlotStart,
      newSlotEnd: newSlotEnd,
      participants: participants,
      ready: ready,
    );
  }
  return state.copyWith(
    newSlotStart: newSlotStart,
    newSlotEnd: newSlotEnd,
    participants: participants,
    ready: ready,
  );
}
