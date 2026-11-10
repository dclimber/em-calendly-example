import 'package:fmodel/fmodel.dart';

import '../../platform/event_store/event_store.dart';
import 'fail_booking/command.dart';
import 'fail_booking/service.dart';

/// Publishes `fail_booking` commands by handling each one on the `meeting` aggregate.
///
/// The publisher lets the decider's sealed error propagate. The handler catches it, because a repeated answer is the
/// expected outcome of a redelivered event.
ActionPublisher<FailBookingCommand, NoMetadata, NoMetadata> createFailBookingPublisher(EventStore eventStore) {
  final service = FailBookingService(eventStore: eventStore);

  Future<void> fail(FailBookingCommand command) => service.handle(command);

  return createActionPublisher(
    publish: (actions) async* {
      await for (final command in actions) {
        await fail(command);
        yield command;
      }
    },
    publishWithMetadata: (actions) async* {
      await for (final (command, metadata) in actions) {
        await fail(command);
        yield (command, metadata);
      }
    },
  );
}
