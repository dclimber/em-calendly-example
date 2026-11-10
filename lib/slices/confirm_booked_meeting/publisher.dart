import 'package:fmodel/fmodel.dart';

import '../../platform/event_store/event_store.dart';
import 'confirm_meeting/command.dart';
import 'confirm_meeting/service.dart';

/// Publishes `confirm_meeting` commands by handling each one on the `meeting` aggregate.
///
/// The publisher lets the decider's sealed error propagate. The handler catches it, because a repeated calendar event
/// is the expected outcome of a redelivered event.
ActionPublisher<ConfirmMeetingCommand, NoMetadata, NoMetadata> createConfirmMeetingPublisher(EventStore eventStore) {
  final service = ConfirmMeetingService(eventStore: eventStore);

  Future<void> confirm(ConfirmMeetingCommand command) => service.handle(command);

  return createActionPublisher(
    publish: (actions) async* {
      await for (final command in actions) {
        await confirm(command);
        yield command;
      }
    },
    publishWithMetadata: (actions) async* {
      await for (final (command, metadata) in actions) {
        await confirm(command);
        yield (command, metadata);
      }
    },
  );
}
