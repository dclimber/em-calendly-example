import '../../../bounded_contexts/meetings/api.dart';
import '../../../platform/event_store/consistent_event_repository.dart';
import '../../../platform/event_store/event_store.dart';
import 'command.dart';

/// Reads the `meeting` history that the live-check decision reads, and appends the request only if none of it changed.
final class RequestBookingAvailabilityCheckEventRepository
    extends ConsistentEventRepository<RequestBookingAvailabilityCheckCommand, MeetingsEvent> {
  RequestBookingAvailabilityCheckEventRepository(super.store);

  @override
  List<EventQuery> queriesFor(RequestBookingAvailabilityCheckCommand command) => [
    (
      tag: 'meetingId',
      value: command.meetingId.value,
      eventTypes: const [
        MeetingSlotReservedEvent,
        BookingAvailabilityCheckRequestedEvent,
        MeetingConfirmedEvent,
        MeetingBookingFailedEvent,
      ],
    ),
  ];
}
