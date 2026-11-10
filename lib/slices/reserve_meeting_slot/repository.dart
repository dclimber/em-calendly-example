import '../../bounded_contexts/employee_directory/api.dart';
import '../../bounded_contexts/host_setup/api.dart';
import '../../bounded_contexts/meetings/api.dart';
import '../../platform/event_store/consistent_event_repository.dart';
import '../../platform/event_store/event_store.dart';
import 'command.dart';

/// Reads the history that a booking decides on, and appends the reservation only if none of it changed.
///
/// The `hostId` query makes every reservation of one host conflict with every other, so two bookings of one host
/// serialize, whatever their meeting type (the model's `no_overlap_spans_the_host` decision).
final class ReserveMeetingSlotEventRepository
    extends ConsistentEventRepository<ReserveMeetingSlotCommand, DomainEvent> {
  ReserveMeetingSlotEventRepository(super.store);

  @override
  List<EventQuery> queriesFor(ReserveMeetingSlotCommand command) => [
    (
      tag: 'meetingTypeId',
      value: command.meetingTypeId.value,
      eventTypes: const [
        MeetingTypeCreatedEvent,
        MeetingTypeEditedEvent,
        MeetingTypeDisabledEvent,
        MeetingTypeEnabledEvent,
        MeetingTypeDeletedEvent,
      ],
    ),
    (
      tag: 'scheduleId',
      value: command.scheduleId.value,
      eventTypes: const [
        AvailabilityScheduleCreatedEvent,
        WeeklyHoursSetEvent,
        DateExceptionAddedEvent,
        DateExceptionChangedEvent,
        DateExceptionRemovedEvent,
        BookingLimitsSetEvent,
      ],
    ),
    (
      tag: 'hostId',
      value: command.hostId.value,
      eventTypes: const [
        CalendarConnectedEvent,
        CalendarConnectionFailedEvent,
        HostBusyTimesRecordedEvent,
        MeetingSlotReservedEvent,
        MeetingRescheduleRequestedEvent,
      ],
    ),
    (tag: 'employeeId', value: command.hostId.value, eventTypes: const [EmployeeRegisteredEvent]),
  ];
}
