import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/corporate_calendar/api.dart';
import '../../../bounded_contexts/meetings/api.dart';
import 'failure_reason.dart';
import 'state.dart';

/// The pure view `failed_calendar_events`: a negative answer of the calendar system lists its meeting, named by the
/// scheduler meeting ref, which is the meeting id, with the reason from [failureReasonOf].
///
/// The `booking_availability_check_requested` event opens no item, so it yields null, like every other event.
final failedCalendarEventsView = View<FailedCalendarEventState?, DomainEvent>(
  initialState: null,
  evolve: (state, event) {
    if (event is! CorporateCalendarEvent) return null;
    final reason = failureReasonOf(event);
    if (reason == null) return null;
    return switch (event) {
      CalendarEventCreationFailedEvent(:final schedulerMeetingRef) ||
      HostSlotFoundBusyEvent(:final schedulerMeetingRef) ||
      AvailabilityCheckFailedEvent(:final schedulerMeetingRef) => FailedCalendarEventState(
        meetingId: MeetingId(schedulerMeetingRef.value),
        failureReason: reason,
      ),
      _ => null,
    };
  },
);
