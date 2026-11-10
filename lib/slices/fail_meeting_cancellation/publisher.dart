import 'package:fmodel/fmodel.dart';

import '../../platform/event_store/event_store.dart';
import 'fail_cancellation/command.dart';
import 'fail_cancellation/service.dart';

/// Publishes `fail_cancellation` commands by handling each one on the `meeting` aggregate.
///
/// The publisher lets the decider's sealed error propagate. The handler catches it, because a repeated answer is the
/// expected outcome of a redelivered event.
ActionPublisher<FailCancellationCommand, NoMetadata, NoMetadata> createFailCancellationPublisher(
  EventStore eventStore,
) {
  final service = FailCancellationService(eventStore: eventStore);

  Future<void> fail(FailCancellationCommand command) => service.handle(command);

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
