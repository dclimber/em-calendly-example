import 'package:fmodel/fmodel.dart';

import '../../platform/event_store/event_store.dart';
import 'record_calendar_connected/command.dart';
import 'record_calendar_connected/service.dart';

/// Publishes `record_calendar_connected` commands by handling each one on the `calendar_connection` aggregate.
///
/// The command carries no sealed error: the decider accepts every command, so the publisher lets any exception
/// propagate, and the event then comes back later.
ActionPublisher<RecordCalendarConnectedCommand, NoMetadata, NoMetadata> createRecordCalendarConnectedPublisher(
  EventStore eventStore,
) {
  final service = RecordCalendarConnectedService(eventStore: eventStore);

  Future<void> record(RecordCalendarConnectedCommand command) => service.handle(command);

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
