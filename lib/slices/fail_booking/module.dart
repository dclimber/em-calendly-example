import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/corporate_calendar/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/event_streaming/event_subscription.dart';
import 'failed_calendar_events/state.dart';
import 'fail_booking/command.dart';
import 'handler.dart';
import 'publisher.dart';
import 'saga.dart';

/// The automation `fail_booking`: records that a booking failed when the calendar system gives a negative answer for a
/// meeting that is still pending_calendar.
final class FailBookingSlice implements VerticalSlice {
  const FailBookingSlice();

  @override
  String get name => 'fail_booking';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final processor = createSagaManager<FailedCalendarEventState, FailBookingCommand, NoMetadata, NoMetadata>(
      saga: calendarFailureTranslatorSaga,
      actionPublisher: createFailBookingPublisher(services.eventStore),
    );
    registrar.subscribe(
      EventSubscription(
        name: 'automation:fail_booking',
        eventTypes: {CalendarEventCreationFailedEvent, HostSlotFoundBusyEvent, AvailabilityCheckFailedEvent},
        handle: (stored) => failBookingHandler(processor, stored),
      ),
    );
  }
}
