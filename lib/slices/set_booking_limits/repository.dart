import '../../bounded_contexts/host_setup/api.dart';
import '../../platform/event_store/consistent_event_repository.dart';
import '../../platform/event_store/event_store.dart';
import 'command.dart';

/// Reads the history of the availability schedule that a command names. The decision needs only its creation.
final class SetBookingLimitsEventRepository extends ConsistentEventRepository<SetBookingLimitsCommand, HostSetupEvent> {
  SetBookingLimitsEventRepository(super.store);

  @override
  List<EventQuery> queriesFor(SetBookingLimitsCommand command) => [
    (
      tag: 'scheduleId',
      value: command.scheduleId.value,
      eventTypes: const [AvailabilityScheduleCreatedEvent],
    ),
  ];
}
