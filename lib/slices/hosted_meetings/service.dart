import '../../bounded_contexts/host_setup/api.dart';
import 'repository.dart';
import 'state.dart';

/// Answers the question of the read model for the page: the confirmed meetings that the host booked through the links,
/// earliest first.
final class HostedMeetingsService {
  HostedMeetingsService({required HostedMeetingsRepository repository}) : _repository = repository;

  final HostedMeetingsRepository _repository;

  Future<List<HostedMeeting>> meetingsHostedBy(HostId hostId) async {
    final meetings = await _repository.findWhere({'hostId': hostId.value});
    return meetings.where((meeting) => meeting.isConfirmed).toList()
      ..sort((a, b) => a.slotStart.value.compareTo(b.slotStart.value));
  }
}
