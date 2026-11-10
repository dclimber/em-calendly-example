import '../../../bounded_contexts/meetings/api.dart';
import '../../../platform/event_store/consistent_event_repository.dart';
import '../../../platform/event_store/event_store.dart';
import 'command.dart';

/// Reads every `meeting` event that the failure decision folds, and appends the failure only if none of them changed.
final class FailRescheduleEventRepository extends ConsistentEventRepository<FailRescheduleCommand, MeetingsEvent> {
  FailRescheduleEventRepository(super.store);

  @override
  List<EventQuery> queriesFor(FailRescheduleCommand command) => [
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
