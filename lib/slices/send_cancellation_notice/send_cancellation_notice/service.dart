import '../../../bounded_contexts/meetings/api.dart';
import '../../../platform/event_store/consistent_event_repository.dart';
import '../../../platform/event_store/event_store.dart';
import 'aggregate.dart';
import 'command.dart';
import 'decider.dart';
import 'errors.dart';
import 'repository.dart';

/// Handles `send_cancellation_notice` on the `meeting` aggregate.
final class SendCancellationNoticeService {
  SendCancellationNoticeService({required EventStore eventStore}) : _eventStore = eventStore;

  final EventStore _eventStore;

  /// Handles the command with a fresh repository, and retries when another writer changed the meeting's history.
  Future<List<MeetingsEvent>> handle(SendCancellationNoticeCommand command) => handleCommand(
    () => buildSendCancellationNoticeAggregate(repository: SendCancellationNoticeEventRepository(_eventStore)),
    command,
  );

  /// A dry run: true when the decider would accept [command] on the meeting's history as it is now. It appends
  /// nothing, so the handler can check before it sends the emails.
  Future<bool> canSend(SendCancellationNoticeCommand command) async {
    final read = await _eventStore.read(sendCancellationNoticeQueries(command.meetingId));
    final state = read.events
        .map((stored) => stored.event as MeetingsEvent)
        .fold(sendCancellationNoticeDecider.initialState, sendCancellationNoticeDecider.evolve);
    try {
      await sendCancellationNoticeDecider.decide(command, state).toList();
      return true;
    } on SendCancellationNoticeError {
      return false;
    }
  }
}
