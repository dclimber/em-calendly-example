import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/corporate_calendar/api.dart';
import '../../../bounded_contexts/meetings/api.dart';
import 'state.dart';

/// The pure view `direct_calendar_deletions`: a `calendar_event_deleted_directly` event lists its meeting.
final directCalendarDeletionsView = View<DirectCalendarDeletionState?, DomainEvent>(
  initialState: null,
  evolve: (state, event) => switch (event) {
    CalendarEventDeletedDirectlyEvent() => DirectCalendarDeletionState(
      meetingId: MeetingId(event.schedulerMeetingRef.value),
    ),
    _ => state,
  },
);
