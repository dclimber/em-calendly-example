import '../../../bounded_contexts/host_setup/api.dart';
import '../../../platform/event_store/consistent_event_repository.dart';
import '../../../platform/event_store/event_store.dart';
import 'aggregate.dart';
import 'command.dart';
import 'repository.dart';

/// Handles `record_connection_failure` on the `calendar_connection` aggregate.
final class RecordConnectionFailureService {
  RecordConnectionFailureService({required EventStore eventStore}) : _eventStore = eventStore;

  final EventStore _eventStore;

  /// Handles the command with a fresh repository, and retries when another writer changed the host's history.
  Future<List<HostSetupEvent>> handle(RecordConnectionFailureCommand command) => handleCommand(
    () => buildRecordConnectionFailureAggregate(repository: RecordConnectionFailureEventRepository(_eventStore)),
    command,
  );
}
