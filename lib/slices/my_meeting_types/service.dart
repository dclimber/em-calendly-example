import '../../bounded_contexts/host_setup/api.dart';
import 'repository.dart';
import 'state.dart';

/// Answers the question of the read model for the page. The view is eventually consistent: a meeting type that was just
/// created may be missing for a moment.
final class MyMeetingTypesService {
  MyMeetingTypesService({required MyMeetingTypesRepository repository}) : _repository = repository;

  final MyMeetingTypesRepository _repository;

  /// The meeting types of [hostId].
  Future<List<MyMeetingType>> meetingTypesOf(HostId hostId) => _repository.findWhere({'hostId': hostId.value});
}
