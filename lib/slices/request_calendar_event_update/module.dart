import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/meetings/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/event_streaming/event_subscription.dart';
import 'handler.dart';
import 'publisher.dart';
import 'request_calendar_event_update/command.dart';
import 'reschedules_awaiting_calendar_update/repository.dart';
import 'reschedules_awaiting_calendar_update/state.dart';
import 'saga.dart';

/// The automation `request_calendar_event_update`: asks the calendar system to move the event of a verified
/// reschedule, once per reschedule request.
final class RequestCalendarEventUpdateSlice implements VerticalSlice {
  const RequestCalendarEventUpdateSlice();

  @override
  String get name => 'request_calendar_event_update';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final processor =
        createSagaManager<
          ReschedulesAwaitingCalendarUpdateState,
          RequestCalendarEventUpdateCommand,
          NoMetadata,
          NoMetadata
        >(
          saga: calendarUpdateRequesterSaga,
          actionPublisher: createRequestCalendarEventUpdatePublisher(services.eventStore),
        );
    final repository = ReschedulesAwaitingCalendarUpdateRepository(services.viewStore);
    registrar.subscribe(
      EventSubscription(
        name: 'automation:request_calendar_event_update',
        eventTypes: {
          MeetingRescheduleRequestedEvent,
          NewSlotVerifiedEvent,
          CalendarEventUpdateRequestedEvent,
          MeetingMovedInCalendarEvent,
          MeetingCanceledEvent,
        },
        handle: (stored) => requestCalendarEventUpdateHandler(processor, repository, stored),
      ),
    );
  }
}
