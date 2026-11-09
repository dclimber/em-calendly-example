import '../../bounded_contexts/host_setup/api.dart';
import 'repository.dart';
import 'state.dart';

/// Answers the question of the read model for the page. The view is eventually consistent: a schedule that was just
/// created may be missing for a moment.
final class MyAvailabilitySchedulesService {
  MyAvailabilitySchedulesService({required MyAvailabilitySchedulesRepository repository}) : _repository = repository;

  final MyAvailabilitySchedulesRepository _repository;

  /// The schedules of [hostId].
  Future<List<AvailabilitySchedule>> schedulesOf(HostId hostId) => _repository.findWhere({'hostId': hostId.value});
}
