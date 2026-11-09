import '../../../bounded_contexts/host_setup/api.dart';
import '../../../platform/event_store/consistent_event_repository.dart';
import '../../../platform/event_store/event_store.dart';
import 'command.dart';

/// Reads the `calendar_connection` history of the host that a command names.
final class RecordCalendarConnectedEventRepository
    extends ConsistentEventRepository<RecordCalendarConnectedCommand, HostSetupEvent> {
  RecordCalendarConnectedEventRepository(super.store);

  @override
  List<EventQuery> queriesFor(RecordCalendarConnectedCommand command) => [
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
