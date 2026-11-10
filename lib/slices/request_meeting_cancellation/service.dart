import '../../bounded_contexts/meetings/api.dart';
import '../../platform/event_store/consistent_event_repository.dart';
import '../../platform/event_store/event_store.dart';
import 'aggregate.dart';
import 'command.dart';
import 'repository.dart';

final class RequestMeetingCancellationService {
  RequestMeetingCancellationService({required EventStore eventStore}) : _eventStore = eventStore;

  final EventStore _eventStore;

  Future<List<DomainEvent>> handle(RequestMeetingCancellationCommand command) => handleCommand(
    () => buildRequestMeetingCancellationAggregate(repository: RequestMeetingCancellationEventRepository(_eventStore)),
    command,
  );
}
