import '../../../bounded_contexts/meetings/api.dart';
import '../../../platform/event_store/consistent_event_repository.dart';
import '../../../platform/event_store/event_store.dart';
import 'command.dart';

/// Reads the `meeting` history that the calendar-event decision reads, and appends the request only if none of it
/// changed.
final class RequestCalendarEventEventRepository
    extends ConsistentEventRepository<RequestCalendarEventCommand, MeetingsEvent> {
  RequestCalendarEventEventRepository(super.store);

  @override
  List<EventQuery> queriesFor(RequestCalendarEventCommand command) => [
    (
      tag: 'meetingId',
      value: command.meetingId.value,
      eventTypes: const [
        MeetingSlotReservedEvent,
        CalendarEventRequestedEvent,
        MeetingConfirmedEvent,
        MeetingBookingFailedEvent,
      ],
    ),
  ];
}
