import '../../../bounded_contexts/meetings/api.dart';
import '../../../platform/event_store/consistent_event_repository.dart';
import '../../../platform/event_store/event_store.dart';
import 'command.dart';

/// Reads every `meeting` event that the cancellation decision folds, and appends the cancellation only if none of them
/// changed.
final class CompleteCancellationEventRepository
    extends ConsistentEventRepository<CompleteCancellationCommand, MeetingsEvent> {
  CompleteCancellationEventRepository(super.store);

  @override
  List<EventQuery> queriesFor(CompleteCancellationCommand command) => [
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
        MeetingMovedInCalendarEvent,
        MeetingCancellationRequestedEvent,
        MeetingCancellationFailedEvent,
        MeetingCanceledEvent,
        MeetingCompletedEvent,
      ],
    ),
  ];
}
