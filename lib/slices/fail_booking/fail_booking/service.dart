import '../../../bounded_contexts/meetings/api.dart';
import '../../../platform/event_store/consistent_event_repository.dart';
import '../../../platform/event_store/event_store.dart';
import 'aggregate.dart';
import 'command.dart';
import 'repository.dart';

/// Handles `fail_booking` on the `meeting` aggregate.
final class FailBookingService {
  FailBookingService({required EventStore eventStore}) : _eventStore = eventStore;

  final EventStore _eventStore;

  /// Handles the command with a fresh repository, and retries when another writer changed the meeting's history.
  Future<List<MeetingsEvent>> handle(FailBookingCommand command) => handleCommand(
    () => buildFailBookingAggregate(repository: FailBookingEventRepository(_eventStore)),
    command,
  );
}
