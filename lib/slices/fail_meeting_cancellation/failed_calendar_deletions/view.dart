import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/corporate_calendar/api.dart';
import '../../../bounded_contexts/meetings/api.dart';
import 'state.dart';

/// The pure view `failed_calendar_deletions`: a `calendar_event_deletion_failed` answer lists its meeting, named by the
/// scheduler meeting ref (the meeting id), with the failure code as the reason. Every other event yields null.
final failedCalendarDeletionsView = View<FailedCalendarDeletionState?, DomainEvent>(
  initialState: null,
  evolve: (state, event) => switch (event) {
    CalendarEventDeletionFailedEvent(:final schedulerMeetingRef, :final failureCode) => FailedCalendarDeletionState(
      meetingId: MeetingId(schedulerMeetingRef.value),
      failureReason: FailureReason(failureCode.value),
    ),
    _ => null,
  },
);
