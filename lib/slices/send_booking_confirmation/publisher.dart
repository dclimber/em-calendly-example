import 'package:fmodel/fmodel.dart';

import '../../platform/event_store/event_store.dart';
import 'send_booking_confirmation/command.dart';
import 'send_booking_confirmation/service.dart';

/// Publishes `send_booking_confirmation` commands by handling each one on the `meeting` aggregate.
///
/// The publisher lets the decider's sealed error propagate. The handler catches it, because a repeated send is the
/// expected outcome of a redelivered event.
ActionPublisher<SendBookingConfirmationCommand, NoMetadata, NoMetadata> createSendBookingConfirmationPublisher(
  EventStore eventStore,
) {
  final service = SendBookingConfirmationService(eventStore: eventStore);

  Future<void> send(SendBookingConfirmationCommand command) => service.handle(command);

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
