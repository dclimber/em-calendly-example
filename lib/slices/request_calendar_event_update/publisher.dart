import 'package:fmodel/fmodel.dart';

import '../../platform/event_store/event_store.dart';
import 'request_calendar_event_update/command.dart';
import 'request_calendar_event_update/service.dart';

/// Publishes `request_calendar_event_update` commands by handling each one on the `meeting` aggregate.
///
/// The publisher lets the decider's sealed error propagate. The handler catches it, because a repeated request is
/// the expected outcome of a redelivered event.
ActionPublisher<RequestCalendarEventUpdateCommand, NoMetadata, NoMetadata> createRequestCalendarEventUpdatePublisher(
  EventStore eventStore,
) {
  final service = RequestCalendarEventUpdateService(eventStore: eventStore);

  Future<void> request(RequestCalendarEventUpdateCommand command) => service.handle(command);

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
