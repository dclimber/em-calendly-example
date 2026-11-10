import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/corporate_calendar/api.dart';
import '../../../bounded_contexts/meetings/api.dart';
import 'state.dart';

/// The pure view `deleted_calendar_events`: a `calendar_event_deleted` event lists its meeting, named by the scheduler
/// meeting ref.
final deletedCalendarEventsView = View<DeletedCalendarEventState?, DomainEvent>(
  initialState: null,
  evolve: (state, event) => switch (event) {
    CalendarEventDeletedEvent() => DeletedCalendarEventState(meetingId: MeetingId(event.schedulerMeetingRef.value)),
    _ => state,
  },
);
