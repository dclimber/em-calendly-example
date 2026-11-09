import '../../../bounded_contexts/host_setup/api.dart';
import '../../../platform/event_store/consistent_event_repository.dart';
import '../../../platform/event_store/event_store.dart';
import 'command.dart';

/// Reads the `calendar_connection` history of the host that a command names.
final class RecordBusyTimesEventRepository extends ConsistentEventRepository<RecordBusyTimesCommand, HostSetupEvent> {
  RecordBusyTimesEventRepository(super.store);

  @override
  List<EventQuery> queriesFor(RecordBusyTimesCommand command) => [
    (
      tag: 'hostId',
      value: command.hostId.value,
      eventTypes: const [
        CalendarConnectionStartedEvent,
        CalendarConnectedEvent,
        CalendarConnectionFailedEvent,
        HostBusyTimesRecordedEvent,
      ],
    ),
  ];
}
