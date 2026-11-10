import '../../bounded_contexts/meetings/api.dart';
import 'repository.dart';
import 'state.dart';

/// Answers the question of the read model for the page: the confirmed meetings that the viewer booked with colleagues,
/// earliest first.
final class MyBookedMeetingsService {
  MyBookedMeetingsService({required MyBookedMeetingsRepository repository}) : _repository = repository;

  final MyBookedMeetingsRepository _repository;

  Future<List<BookedMeeting>> meetingsBookedBy(BookerId bookerId) async {
    final meetings = await _repository.findWhere({'bookerId': bookerId.value});
    return meetings.where((meeting) => meeting.isConfirmed).toList()
      ..sort((a, b) => a.slotStart.value.compareTo(b.slotStart.value));
  }
}
