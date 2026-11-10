import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/corporate_calendar/api.dart';
import '../../../bounded_contexts/meetings/api.dart';
import 'state.dart';

/// The pure view `created_calendar_events`: a `calendar_event_created` event lists its meeting, named by the scheduler
/// meeting ref, with the provider's event ref as the calendar event id.
final createdCalendarEventsView = View<CreatedCalendarEventState?, DomainEvent>(
  initialState: null,
  evolve: (state, event) => switch (event) {
    CalendarEventCreatedEvent() => CreatedCalendarEventState(
      meetingId: MeetingId(event.schedulerMeetingRef.value),
      calendarEventId: CalendarEventId(event.providerEventRef),
    ),
    _ => state,
  },
);
