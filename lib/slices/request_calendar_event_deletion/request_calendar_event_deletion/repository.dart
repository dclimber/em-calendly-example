import '../../../bounded_contexts/meetings/api.dart';
import '../../../platform/event_store/consistent_event_repository.dart';
import '../../../platform/event_store/event_store.dart';
import 'command.dart';

/// Reads the `meeting` history that the calendar-deletion decision reads, and appends the request only if none of it
/// changed.
final class RequestCalendarEventDeletionEventRepository
    extends ConsistentEventRepository<RequestCalendarEventDeletionCommand, MeetingsEvent> {
  RequestCalendarEventDeletionEventRepository(super.store);

  @override
  List<EventQuery> queriesFor(RequestCalendarEventDeletionCommand command) => [
    (
      tag: 'meetingId',
      value: command.meetingId.value,
      eventTypes: const [
        MeetingCancellationRequestedEvent,
        CalendarEventDeletionRequestedEvent,
        MeetingCancellationFailedEvent,
        MeetingCanceledEvent,
      ],
    ),
  ];
}
