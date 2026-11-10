import 'package:fmodel/fmodel.dart';

import '../../platform/event_store/event_store.dart';
import 'send_reschedule_notice/command.dart';
import 'send_reschedule_notice/service.dart';

/// Publishes `send_reschedule_notice` commands by handling each one on the `meeting` aggregate.
///
/// The publisher lets the decider's sealed error propagate. The handler catches it, because a repeated notice is the
/// expected outcome of a redelivered event.
ActionPublisher<SendRescheduleNoticeCommand, NoMetadata, NoMetadata> createSendRescheduleNoticePublisher(
  EventStore eventStore,
) {
  final service = SendRescheduleNoticeService(eventStore: eventStore);

  Future<void> send(SendRescheduleNoticeCommand command) => service.handle(command);

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
