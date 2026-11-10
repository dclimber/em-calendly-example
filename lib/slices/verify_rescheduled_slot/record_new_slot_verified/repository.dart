import '../../../bounded_contexts/meetings/api.dart';
import '../../../platform/event_store/consistent_event_repository.dart';
import '../../../platform/event_store/event_store.dart';
import 'command.dart';

/// Reads the `meeting` history that the verification decision reads, and appends the verification only if none of it
/// changed.
final class RecordNewSlotVerifiedEventRepository
    extends ConsistentEventRepository<RecordNewSlotVerifiedCommand, MeetingsEvent> {
  RecordNewSlotVerifiedEventRepository(super.store);

  @override
  List<EventQuery> queriesFor(RecordNewSlotVerifiedCommand command) => [
    (
      tag: 'meetingId',
      value: command.meetingId.value,
      eventTypes: const [
        MeetingSlotReservedEvent,
        MeetingConfirmedEvent,
        MeetingBookingFailedEvent,
        MeetingRescheduleRequestedEvent,
        NewSlotVerifiedEvent,
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
