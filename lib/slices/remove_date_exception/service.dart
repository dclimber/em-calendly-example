import '../../bounded_contexts/host_setup/api.dart';
import '../../platform/event_store/consistent_event_repository.dart';
import '../../platform/event_store/event_store.dart';
import 'aggregate.dart';
import 'command.dart';
import 'repository.dart';

final class RemoveDateExceptionService {
  RemoveDateExceptionService({required EventStore eventStore}) : _eventStore = eventStore;

  final EventStore _eventStore;

  /// Handles the command with a fresh repository, and retries when another writer changed the schedule's history.
  Future<List<HostSetupEvent>> handle(RemoveDateExceptionCommand command) => handleCommand(
    () => buildRemoveDateExceptionAggregate(repository: RemoveDateExceptionEventRepository(_eventStore)),
    command,
  );
}
