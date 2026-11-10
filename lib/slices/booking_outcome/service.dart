import '../../bounded_contexts/meetings/api.dart';
import 'repository.dart';
import 'state.dart';

/// Answers the question of the read model for the page. The view is eventually consistent: a reservation that was just
/// made may be missing for a moment, and the page then shows it as being confirmed.
final class BookingOutcomeService {
  BookingOutcomeService({required BookingOutcomeRepository repository}) : _repository = repository;

  final BookingOutcomeRepository _repository;

  /// The outcome of the booking of [meetingId], or null while the view has no document for it.
  Future<BookingOutcome?> outcomeOf(MeetingId meetingId) => _repository.load(meetingId.value);
}
