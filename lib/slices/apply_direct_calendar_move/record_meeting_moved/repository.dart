import '../../../bounded_contexts/meetings/api.dart';
import '../../../platform/event_store/consistent_event_repository.dart';
import '../../../platform/event_store/event_store.dart';
import 'command.dart';

/// The `meeting` event types that fold into the lifecycle: the decision and the processor history read the same ones.
const meetingLifecycleEventTypes = <Type>[
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
];

/// Reads every `meeting` lifecycle event that the direct-move decision folds, and appends the move only if none of them
/// changed.
final class RecordMeetingMovedEventRepository
    extends ConsistentEventRepository<RecordMeetingMovedCommand, MeetingsEvent> {
  RecordMeetingMovedEventRepository(super.store);

  @override
  List<EventQuery> queriesFor(RecordMeetingMovedCommand command) => [
    (tag: 'meetingId', value: command.meetingId.value, eventTypes: meetingLifecycleEventTypes),
  ];
}
