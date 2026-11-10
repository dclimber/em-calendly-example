import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/meetings/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/event_streaming/event_subscription.dart';
import 'handler.dart';
import 'publisher.dart';
import 'request_calendar_event/command.dart';
import 'reservations_awaiting_calendar_event/repository.dart';
import 'reservations_awaiting_calendar_event/state.dart';
import 'saga.dart';

/// The automation `request_calendar_event`: asks the calendar system to create the event of a verified reservation,
/// once per reservation.
final class RequestCalendarEventSlice implements VerticalSlice {
  const RequestCalendarEventSlice();

  @override
  String get name => 'request_calendar_event';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final processor =
        createSagaManager<ReservationAwaitingCalendarEventState, RequestCalendarEventCommand, NoMetadata, NoMetadata>(
          saga: calendarEventRequesterSaga,
          actionPublisher: createRequestCalendarEventPublisher(services.eventStore),
        );
    final repository = ReservationsAwaitingCalendarEventRepository(services.viewStore);
    registrar.subscribe(
      EventSubscription(
        name: 'automation:request_calendar_event',
        eventTypes: {MeetingSlotReservedEvent, BookingSlotVerifiedEvent, CalendarEventRequestedEvent},
        handle: (stored) => requestCalendarEventHandler(processor, repository, stored),
      ),
    );
  }
}
