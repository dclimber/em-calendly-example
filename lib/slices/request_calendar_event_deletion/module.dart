import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/meetings/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/event_streaming/event_subscription.dart';
import 'cancellations_awaiting_calendar_deletion/repository.dart';
import 'cancellations_awaiting_calendar_deletion/state.dart';
import 'handler.dart';
import 'publisher.dart';
import 'request_calendar_event_deletion/command.dart';
import 'saga.dart';

/// The automation `request_calendar_event_deletion`: asks the calendar system to remove the event of a requested
/// cancellation, once per cancellation.
final class RequestCalendarEventDeletionSlice implements VerticalSlice {
  const RequestCalendarEventDeletionSlice();

  @override
  String get name => 'request_calendar_event_deletion';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final processor =
        createSagaManager<
          CancellationAwaitingCalendarDeletionState,
          RequestCalendarEventDeletionCommand,
          NoMetadata,
          NoMetadata
        >(
          saga: calendarDeletionRequesterSaga,
          actionPublisher: createRequestCalendarEventDeletionPublisher(services.eventStore),
        );
    final repository = CancellationsAwaitingCalendarDeletionRepository(services.viewStore);
    registrar.subscribe(
      EventSubscription(
        name: 'automation:request_calendar_event_deletion',
        eventTypes: {MeetingCancellationRequestedEvent, CalendarEventDeletionRequestedEvent, MeetingCanceledEvent},
        handle: (stored) => requestCalendarEventDeletionHandler(processor, repository, stored),
      ),
    );
  }
}
