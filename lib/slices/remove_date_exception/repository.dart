import '../../bounded_contexts/host_setup/api.dart';
import '../../platform/event_store/consistent_event_repository.dart';
import '../../platform/event_store/event_store.dart';
import 'command.dart';

/// Reads the history of the availability schedule that a command names. The decision folds only the schedule's
/// creation, so that is the only event type it reads.
final class RemoveDateExceptionEventRepository
    extends ConsistentEventRepository<RemoveDateExceptionCommand, HostSetupEvent> {
  RemoveDateExceptionEventRepository(super.store);

  @override
  List<EventQuery> queriesFor(RemoveDateExceptionCommand command) => [
    (
      tag: 'scheduleId',
      value: command.scheduleId.value,
      eventTypes: const [AvailabilityScheduleCreatedEvent],
    ),
  ];
}
