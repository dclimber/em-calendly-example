import '../../bounded_contexts/host_setup/api.dart';
import '../../platform/event_store/consistent_event_repository.dart';
import '../../platform/event_store/event_store.dart';
import 'command.dart';

/// Reads the history of the availability schedule that a command names.
final class CreateAvailabilityScheduleEventRepository
    extends ConsistentEventRepository<CreateAvailabilityScheduleCommand, HostSetupEvent> {
  CreateAvailabilityScheduleEventRepository(super.store);

  @override
  List<EventQuery> queriesFor(CreateAvailabilityScheduleCommand command) => [
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
  ];
}
