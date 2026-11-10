import '../../../bounded_contexts/meetings/api.dart';
import '../../../platform/event_store/consistent_event_repository.dart';
import '../../../platform/event_store/event_store.dart';
import 'aggregate.dart';
import 'command.dart';
import 'decider.dart';
import 'errors.dart';
import 'repository.dart';

/// Handles `send_booking_confirmation` on the `meeting` aggregate.
final class SendBookingConfirmationService {
  SendBookingConfirmationService({required EventStore eventStore}) : _eventStore = eventStore;

  final EventStore _eventStore;

  /// Handles the command with a fresh repository, and retries when another writer changed the meeting's history.
  Future<List<MeetingsEvent>> handle(SendBookingConfirmationCommand command) => handleCommand(
    () => buildSendBookingConfirmationAggregate(repository: SendBookingConfirmationEventRepository(_eventStore)),
    command,
  );

  /// A dry run: true when the decider would accept [command] on the meeting's history as it is now. It appends
  /// nothing, so the handler can check before it sends the email.
  Future<bool> canSend(SendBookingConfirmationCommand command) async {
    final read = await _eventStore.read(sendBookingConfirmationQueries(command.meetingId));
    final state = read.events
        .map((stored) => stored.event as MeetingsEvent)
        .fold(sendBookingConfirmationDecider.initialState, sendBookingConfirmationDecider.evolve);
    try {
      await sendBookingConfirmationDecider.decide(command, state).toList();
      return true;
    } on SendBookingConfirmationError {
      return false;
    }
  }
}
