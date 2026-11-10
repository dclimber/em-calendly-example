import 'package:fmodel/fmodel.dart';

import '../../platform/event_store/event_store.dart';
import 'record_meeting_moved/command.dart';
import 'record_meeting_moved/service.dart';

/// Publishes `record_meeting_moved` commands by handling each one on the `meeting` aggregate.
///
/// The publisher lets the decider's sealed error propagate. The handler catches it: a refused direct move is a valid
/// outcome, not a failure.
ActionPublisher<RecordMeetingMovedCommand, NoMetadata, NoMetadata> createRecordMeetingMovedPublisher(
  EventStore eventStore,
) {
  final service = RecordMeetingMovedService(eventStore: eventStore);

  Future<void> record(RecordMeetingMovedCommand command) => service.handle(command);

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
