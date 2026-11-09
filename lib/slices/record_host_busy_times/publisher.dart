import 'package:fmodel/fmodel.dart';

import '../../platform/event_store/event_store.dart';
import 'record_busy_times/command.dart';
import 'record_busy_times/service.dart';

/// Publishes `record_busy_times` commands by handling each one on the `calendar_connection` aggregate.
///
/// The command carries no sealed error: the decider accepts every command, so the publisher lets any exception
/// propagate, and the event then comes back later.
ActionPublisher<RecordBusyTimesCommand, NoMetadata, NoMetadata> createRecordBusyTimesPublisher(EventStore eventStore) {
  final service = RecordBusyTimesService(eventStore: eventStore);

  Future<void> record(RecordBusyTimesCommand command) => service.handle(command);

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
