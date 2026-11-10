import 'package:fmodel/fmodel.dart';

import '../../platform/event_store/event_store.dart';
import 'send_cancellation_notice/command.dart';
import 'send_cancellation_notice/service.dart';

/// Publishes `send_cancellation_notice` commands by handling each one on the `meeting` aggregate.
///
/// The publisher lets the decider's sealed error propagate. The handler catches it, because a repeated notice is the
/// expected outcome of a redelivered event.
ActionPublisher<SendCancellationNoticeCommand, NoMetadata, NoMetadata> createSendCancellationNoticePublisher(
  EventStore eventStore,
) {
  final service = SendCancellationNoticeService(eventStore: eventStore);

  Future<void> send(SendCancellationNoticeCommand command) => service.handle(command);

  return createActionPublisher(
    publish: (actions) async* {
      await for (final command in actions) {
        await send(command);
        yield command;
      }
    },
    publishWithMetadata: (actions) async* {
      await for (final (command, metadata) in actions) {
        await send(command);
        yield (command, metadata);
      }
    },
  );
}
