import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/corporate_calendar/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/event_streaming/event_subscription.dart';
import 'confirm_meeting/command.dart';
import 'handler.dart';
import 'publisher.dart';
import 'saga.dart';

/// The automation `confirm_booked_meeting`: a translation of the calendar system's created event. It confirms the
/// meeting that the calendar event belongs to, while the meeting is still pending_calendar.
final class ConfirmBookedMeetingSlice implements VerticalSlice {
  const ConfirmBookedMeetingSlice();

  @override
  String get name => 'confirm_booked_meeting';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final processor = createSagaManager<CalendarCreatedTranslatorInput, ConfirmMeetingCommand, NoMetadata, NoMetadata>(
      saga: calendarCreatedTranslatorSaga,
      actionPublisher: createConfirmMeetingPublisher(services.eventStore),
    );
    registrar.subscribe(
      EventSubscription(
        name: 'automation:confirm_booked_meeting',
        eventTypes: {CalendarEventCreatedEvent},
        handle: (stored) => confirmBookedMeetingHandler(processor, services.eventStore, stored),
      ),
    );
  }
}
