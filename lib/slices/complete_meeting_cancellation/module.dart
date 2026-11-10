import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/corporate_calendar/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/event_streaming/event_subscription.dart';
import 'complete_cancellation/command.dart';
import 'deleted_calendar_events/state.dart';
import 'handler.dart';
import 'publisher.dart';
import 'saga.dart';

/// The automation `complete_meeting_cancellation`: a translation of the calendar system's deleted event. It completes the
/// cancellation of the meeting that the calendar event belongs to, while the meeting is still canceling.
final class CompleteMeetingCancellationSlice implements VerticalSlice {
  const CompleteMeetingCancellationSlice();

  @override
  String get name => 'complete_meeting_cancellation';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final processor = createSagaManager<DeletedCalendarEventState, CompleteCancellationCommand, NoMetadata, NoMetadata>(
      saga: calendarDeletedTranslatorSaga,
      actionPublisher: createCompleteCancellationPublisher(services.eventStore),
    );
    registrar.subscribe(
      EventSubscription(
        name: 'automation:complete_meeting_cancellation',
        eventTypes: {CalendarEventDeletedEvent},
        handle: (stored) => completeMeetingCancellationHandler(processor, stored),
      ),
    );
  }
}
