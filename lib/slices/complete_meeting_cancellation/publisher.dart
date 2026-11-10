import 'package:fmodel/fmodel.dart';

import '../../platform/event_store/event_store.dart';
import 'complete_cancellation/command.dart';
import 'complete_cancellation/service.dart';

/// Publishes `complete_cancellation` commands by handling each one on the `meeting` aggregate.
///
/// The publisher lets the decider's sealed error propagate. The handler catches it, because a repeated calendar event
/// is the expected outcome of a redelivered event.
ActionPublisher<CompleteCancellationCommand, NoMetadata, NoMetadata> createCompleteCancellationPublisher(
  EventStore eventStore,
) {
  final service = CompleteCancellationService(eventStore: eventStore);

  Future<void> complete(CompleteCancellationCommand command) => service.handle(command);

  return createActionPublisher(
    publish: (actions) async* {
      await for (final command in actions) {
        await complete(command);
        yield command;
      }
    },
    publishWithMetadata: (actions) async* {
      await for (final (command, metadata) in actions) {
        await complete(command);
        yield (command, metadata);
      }
    },
  );
}
