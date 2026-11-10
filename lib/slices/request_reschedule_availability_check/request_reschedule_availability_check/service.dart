import '../../../bounded_contexts/meetings/api.dart';
import '../../../platform/event_store/consistent_event_repository.dart';
import '../../../platform/event_store/event_store.dart';
import 'aggregate.dart';
import 'command.dart';
import 'repository.dart';

/// Handles `request_reschedule_availability_check` on the `meeting` aggregate.
final class RequestRescheduleAvailabilityCheckService {
  RequestRescheduleAvailabilityCheckService({required EventStore eventStore}) : _eventStore = eventStore;

  final EventStore _eventStore;

  /// Handles the command with a fresh repository, and retries when another writer changed the meeting's history.
  Future<List<MeetingsEvent>> handle(RequestRescheduleAvailabilityCheckCommand command) => handleCommand(
    () => buildRequestRescheduleAvailabilityCheckAggregate(
      repository: RequestRescheduleAvailabilityCheckEventRepository(_eventStore),
    ),
    command,
  );
}
