import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'state.dart';

/// The pure view `cancellations_awaiting_calendar_deletion`. A requested cancellation opens its item, and the item
/// leaves the list when `calendar_event_deletion_requested` arrives or when the meeting is canceled directly (the
/// event is already gone from the calendar). A null state deletes the item.
final cancellationsAwaitingCalendarDeletionView = View<CancellationAwaitingCalendarDeletionState?, MeetingsEvent>(
  initialState: null,
  evolve: (state, event) => switch (event) {
    MeetingCancellationRequestedEvent() => CancellationAwaitingCalendarDeletionState(
      meetingId: event.meetingId,
      calendarEventId: event.calendarEventId,
    ),
    CalendarEventDeletionRequestedEvent() => null,
    MeetingCanceledEvent() => null,
    _ => state,
  },
);
