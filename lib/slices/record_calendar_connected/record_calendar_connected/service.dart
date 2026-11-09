import '../../../bounded_contexts/host_setup/api.dart';
import '../../../platform/event_store/consistent_event_repository.dart';
import '../../../platform/event_store/event_store.dart';
import 'aggregate.dart';
import 'command.dart';
import 'repository.dart';

/// Handles `record_calendar_connected` on the `calendar_connection` aggregate.
final class RecordCalendarConnectedService {
  RecordCalendarConnectedService({required EventStore eventStore}) : _eventStore = eventStore;

  final EventStore _eventStore;

  /// Handles the command with a fresh repository, and retries when another writer changed the host's history.
  Future<List<HostSetupEvent>> handle(RecordCalendarConnectedCommand command) => handleCommand(
    () => buildRecordCalendarConnectedAggregate(repository: RecordCalendarConnectedEventRepository(_eventStore)),
    command,
  );
}
