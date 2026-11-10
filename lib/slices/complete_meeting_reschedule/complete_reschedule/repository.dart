import '../../../bounded_contexts/meetings/api.dart';
import '../../../platform/event_store/consistent_event_repository.dart';
import '../../../platform/event_store/event_store.dart';
import 'command.dart';

/// Reads every `meeting` event that the completion decision folds, and appends the completion only if none of them
/// changed.
final class CompleteRescheduleEventRepository
    extends ConsistentEventRepository<CompleteRescheduleCommand, MeetingsEvent> {
  CompleteRescheduleEventRepository(super.store);

  @override
  List<EventQuery> queriesFor(CompleteRescheduleCommand command) => [
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
        MeetingCanceledEvent,
        MeetingCompletedEvent,
      ],
    ),
  ];
}
