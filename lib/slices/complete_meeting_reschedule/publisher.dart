import 'package:fmodel/fmodel.dart';

import '../../platform/event_store/event_store.dart';
import 'complete_reschedule/command.dart';
import 'complete_reschedule/service.dart';

/// Publishes `complete_reschedule` commands by handling each one on the `meeting` aggregate.
///
/// The publisher lets the decider's sealed error propagate. The handler catches it, because a repeated calendar event
/// is the expected outcome of a redelivered event.
ActionPublisher<CompleteRescheduleCommand, NoMetadata, NoMetadata> createCompleteRescheduePublisher(
  EventStore eventStore,
) {
  final service = CompleteRescheduleService(eventStore: eventStore);

  Future<void> complete(CompleteRescheduleCommand command) => service.handle(command);

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
