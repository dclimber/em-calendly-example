import '../../../bounded_contexts/meetings/api.dart';
import '../../../platform/event_store/consistent_event_repository.dart';
import '../../../platform/event_store/event_store.dart';
import 'aggregate.dart';
import 'command.dart';
import 'repository.dart';

/// Handles `request_booking_availability_check` on the `meeting` aggregate.
final class RequestBookingAvailabilityCheckService {
  RequestBookingAvailabilityCheckService({required EventStore eventStore}) : _eventStore = eventStore;

  final EventStore _eventStore;

  /// Handles the command with a fresh repository, and retries when another writer changed the meeting's history.
  Future<List<MeetingsEvent>> handle(RequestBookingAvailabilityCheckCommand command) => handleCommand(
    () => buildRequestBookingAvailabilityCheckAggregate(
      repository: RequestBookingAvailabilityCheckEventRepository(_eventStore),
    ),
    command,
  );
}
