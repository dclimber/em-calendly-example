import '../../bounded_contexts/host_setup/api.dart';
import '../../bounded_contexts/meetings/api.dart';
import '../../platform/event_store/consistent_event_repository.dart';
import '../../platform/event_store/event_store.dart';
import 'command.dart';

/// The meeting events that the decision folds, and the host events that hold its schedule and calendar state.
const _meetingEventTypes = [
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
];

final class RequestMeetingRescheduleEventRepository
    extends ConsistentEventRepository<RequestMeetingRescheduleCommand, DomainEvent> {
  RequestMeetingRescheduleEventRepository(super.store);

  @override
  List<EventQuery> queriesFor(RequestMeetingRescheduleCommand command) => [
    (tag: 'meetingId', value: command.meetingId.value, eventTypes: _meetingEventTypes),
    (
      tag: 'hostId',
      value: command.hostId.value,
      eventTypes: [
        AvailabilityScheduleCreatedEvent,
        WeeklyHoursSetEvent,
        DateExceptionAddedEvent,
        DateExceptionChangedEvent,
        DateExceptionRemovedEvent,
        BookingLimitsSetEvent,
        CalendarConnectedEvent,
        CalendarConnectionFailedEvent,
        HostBusyTimesRecordedEvent,
        ..._meetingEventTypes,
      ],
    ),
  ];
}
