import 'package:fmodel/fmodel.dart';

import '../../platform/event_store/event_store.dart';
import 'request_calendar_event_deletion/command.dart';
import 'request_calendar_event_deletion/service.dart';

/// Publishes `request_calendar_event_deletion` commands by handling each one on the `meeting` aggregate.
///
/// The publisher lets the decider's sealed error propagate. The handler catches it, because a repeated request is the
/// expected outcome of a redelivered event.
ActionPublisher<RequestCalendarEventDeletionCommand, NoMetadata, NoMetadata>
createRequestCalendarEventDeletionPublisher(
  EventStore eventStore,
) {
  final service = RequestCalendarEventDeletionService(eventStore: eventStore);

  Future<void> request(RequestCalendarEventDeletionCommand command) => service.handle(command);

  return createActionPublisher(
    publish: (actions) async* {
      await for (final command in actions) {
        await request(command);
        yield command;
      }
    },
    publishWithMetadata: (actions) async* {
      await for (final (command, metadata) in actions) {
        await request(command);
        yield (command, metadata);
      }
    },
  );
}
