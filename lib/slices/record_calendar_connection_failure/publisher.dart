import 'package:fmodel/fmodel.dart';

import '../../platform/event_store/event_store.dart';
import 'record_connection_failure/command.dart';
import 'record_connection_failure/service.dart';

/// Publishes `record_connection_failure` commands by handling each one on the `calendar_connection` aggregate.
///
/// The command carries no sealed error: the decider accepts every command, so the publisher lets any exception
/// propagate, and the event then comes back later.
ActionPublisher<RecordConnectionFailureCommand, NoMetadata, NoMetadata> createRecordConnectionFailurePublisher(
  EventStore eventStore,
) {
  final service = RecordConnectionFailureService(eventStore: eventStore);

  Future<void> record(RecordConnectionFailureCommand command) => service.handle(command);

  return createActionPublisher(
    publish: (actions) async* {
      await for (final command in actions) {
        await record(command);
        yield command;
      }
    },
    publishWithMetadata: (actions) async* {
      await for (final (command, metadata) in actions) {
        await record(command);
        yield (command, metadata);
      }
    },
  );
}
