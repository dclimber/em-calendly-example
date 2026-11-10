import '../../bounded_contexts/meetings/api.dart';
import '../../platform/event_store/consistent_event_repository.dart';
import '../../platform/event_store/event_store.dart';
import 'command.dart';

/// The meeting events that the cancellation decision folds. Every one carries the `meetingId` tag.
const _meetingEventTypes = [
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
];

final class RequestMeetingCancellationEventRepository
    extends ConsistentEventRepository<RequestMeetingCancellationCommand, DomainEvent> {
  RequestMeetingCancellationEventRepository(super.store);

  @override
  List<EventQuery> queriesFor(RequestMeetingCancellationCommand command) => [
    (tag: 'meetingId', value: command.meetingId.value, eventTypes: _meetingEventTypes),
  ];
}
