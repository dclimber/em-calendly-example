import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'state.dart';

/// The pure view `reschedules_awaiting_calendar_update`. A reschedule is opened by `meeting_reschedule_requested`
/// (unverified) and marked verified by `new_slot_verified`. It leaves the list when `calendar_event_update_requested`,
/// `meeting_moved_in_calendar`, or `meeting_canceled` arrives (a null state deletes the item).
///
/// A redelivered `meeting_reschedule_requested` keeps the verification it already has.
final reschedulesAwaitingCalendarUpdateView = View<ReschedulesAwaitingCalendarUpdateState?, MeetingsEvent>(
  initialState: null,
  evolve: (state, event) => switch (event) {
    MeetingRescheduleRequestedEvent() => ReschedulesAwaitingCalendarUpdateState(
      meetingId: event.meetingId,
      newSlotStart: event.newSlotStart,
      newSlotEnd: event.newSlotEnd,
      calendarEventId: event.calendarEventId,
      verified: state?.verified ?? false,
    ),
    NewSlotVerifiedEvent() => state?.copyWith(verified: true),
    CalendarEventUpdateRequestedEvent() || MeetingMovedInCalendarEvent() || MeetingCanceledEvent() => null,
    _ => state,
  },
);
