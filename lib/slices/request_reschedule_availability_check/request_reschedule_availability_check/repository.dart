import '../../../bounded_contexts/meetings/api.dart';
import '../../../platform/event_store/consistent_event_repository.dart';
import '../../../platform/event_store/event_store.dart';
import 'command.dart';

/// Reads the `meeting` history that the reschedule live-check decision reads, and appends the request only if none of
/// it changed.
final class RequestRescheduleAvailabilityCheckEventRepository
    extends ConsistentEventRepository<RequestRescheduleAvailabilityCheckCommand, MeetingsEvent> {
  RequestRescheduleAvailabilityCheckEventRepository(super.store);

  @override
  List<EventQuery> queriesFor(RequestRescheduleAvailabilityCheckCommand command) => [
    (
      tag: 'meetingId',
      value: command.meetingId.value,
      eventTypes: const [
        MeetingSlotReservedEvent,
        MeetingConfirmedEvent,
        MeetingBookingFailedEvent,
        MeetingRescheduleRequestedEvent,
        RescheduleAvailabilityCheckRequestedEvent,
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
