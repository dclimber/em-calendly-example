import '../../../bounded_contexts/meetings/api.dart';
import '../../../platform/event_store/consistent_event_repository.dart';
import '../../../platform/event_store/event_store.dart';
import 'command.dart';

/// Reads the `meeting` history that the calendar-update decision reads, and appends the update only if none of it
/// changed.
final class RequestCalendarEventUpdateEventRepository
    extends ConsistentEventRepository<RequestCalendarEventUpdateCommand, MeetingsEvent> {
  RequestCalendarEventUpdateEventRepository(super.store);

  @override
  List<EventQuery> queriesFor(RequestCalendarEventUpdateCommand command) => [
    (
      tag: 'meetingId',
      value: command.meetingId.value,
      eventTypes: const [
        MeetingSlotReservedEvent,
        MeetingConfirmedEvent,
        MeetingBookingFailedEvent,
        MeetingRescheduleRequestedEvent,
        CalendarEventUpdateRequestedEvent,
        MeetingRescheduledEvent,
        MeetingRescheduleFailedEvent,
        MeetingMovedInCalendarEvent,
        MeetingCancellationRequestedEvent,
        MeetingCanceledEvent,
        MeetingCompletedEvent,
      ],
    ),
  ];
}
