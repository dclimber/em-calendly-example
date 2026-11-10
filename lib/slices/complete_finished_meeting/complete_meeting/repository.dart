import '../../../bounded_contexts/meetings/api.dart';
import '../../../platform/event_store/consistent_event_repository.dart';
import '../../../platform/event_store/event_store.dart';
import 'command.dart';

/// Reads the `meeting` history that the completion decision reads, and appends the completion only if none of it changed.
final class CompleteMeetingEventRepository extends ConsistentEventRepository<CompleteMeetingCommand, MeetingsEvent> {
  CompleteMeetingEventRepository(super.store);

  @override
  List<EventQuery> queriesFor(CompleteMeetingCommand command) => [
    (
      tag: 'meetingId',
      value: command.meetingId.value,
      eventTypes: const [
        MeetingSlotReservedEvent,
        MeetingConfirmedEvent,
        MeetingBookingFailedEvent,
        MeetingRescheduleRequestedEvent,
        MeetingRescheduledEvent,
        MeetingRescheduleFailedEvent,
        MeetingCancellationRequestedEvent,
        MeetingCancellationFailedEvent,
        MeetingCanceledEvent,
        MeetingCompletedEvent,
      ],
    ),
  ];
}
