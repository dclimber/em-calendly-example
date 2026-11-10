import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/corporate_calendar/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/event_streaming/event_subscription.dart';
import 'complete_reschedule/command.dart';
import 'handler.dart';
import 'publisher.dart';
import 'saga.dart';
import 'updated_calendar_events/state.dart';

/// The automation `complete_meeting_reschedule`: a translation of the calendar system's updated event. It completes the
/// reschedule of the meeting that the calendar event belongs to, while the meeting is still rescheduling.
final class CompleteMeetingRescheduleSlice implements VerticalSlice {
  const CompleteMeetingRescheduleSlice();

  @override
  String get name => 'complete_meeting_reschedule';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final processor = createSagaManager<UpdatedCalendarEventState, CompleteRescheduleCommand, NoMetadata, NoMetadata>(
      saga: calendarUpdatedTranslatorSaga,
      actionPublisher: createCompleteRescheduePublisher(services.eventStore),
    );
    registrar.subscribe(
      EventSubscription(
        name: 'automation:complete_meeting_reschedule',
        eventTypes: {CalendarEventUpdatedEvent},
        handle: (stored) => completeMeetingRescheduleHandler(processor, stored),
      ),
    );
  }
}
