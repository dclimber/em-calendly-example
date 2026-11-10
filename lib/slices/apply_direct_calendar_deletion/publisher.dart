import 'package:fmodel/fmodel.dart';

import '../../platform/event_store/event_store.dart';
import 'record_meeting_deleted/command.dart';
import 'record_meeting_deleted/service.dart';

/// Publishes `record_meeting_deleted` commands by handling each one on the `meeting` aggregate.
///
/// The publisher lets the decider's sealed error propagate. The handler catches it: a refused direct deletion is a valid
/// outcome, not a failure.
ActionPublisher<RecordMeetingDeletedCommand, NoMetadata, NoMetadata> createRecordMeetingDeletedPublisher(
  EventStore eventStore,
) {
  final service = RecordMeetingDeletedService(eventStore: eventStore);

  Future<void> record(RecordMeetingDeletedCommand command) => service.handle(command);

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
