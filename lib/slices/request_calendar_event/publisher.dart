import 'package:fmodel/fmodel.dart';

import '../../platform/event_store/event_store.dart';
import 'request_calendar_event/command.dart';
import 'request_calendar_event/service.dart';

/// Publishes `request_calendar_event` commands by handling each one on the `meeting` aggregate.
///
/// The publisher lets the decider's sealed error propagate. The handler catches it, because a repeated request is
/// the expected outcome of a redelivered event.
ActionPublisher<RequestCalendarEventCommand, NoMetadata, NoMetadata> createRequestCalendarEventPublisher(
  EventStore eventStore,
) {
  final service = RequestCalendarEventService(eventStore: eventStore);

  Future<void> request(RequestCalendarEventCommand command) => service.handle(command);

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
