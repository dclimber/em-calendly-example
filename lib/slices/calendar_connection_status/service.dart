import '../../bounded_contexts/host_setup/api.dart';
import 'repository.dart';
import 'state.dart';

/// Answers the question of the read model for the page. The view is eventually consistent: `null` means that no
/// event has reached the view yet.
final class CalendarConnectionStatusService {
  CalendarConnectionStatusService({required CalendarConnectionStatusRepository repository}) : _repository = repository;

  final CalendarConnectionStatusRepository _repository;

  Future<CalendarConnectionStatus?> statusFor(HostId hostId) => _repository.load(hostId.value);
}
