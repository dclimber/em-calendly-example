import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/corporate_calendar/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/event_streaming/event_subscription.dart';
import 'fail_cancellation/command.dart';
import 'failed_calendar_deletions/state.dart';
import 'handler.dart';
import 'publisher.dart';
import 'saga.dart';

/// The automation `fail_meeting_cancellation`: records that a cancellation failed when the calendar system could not remove
/// the event of a canceling meeting. The meeting stays confirmed.
final class FailMeetingCancellationSlice implements VerticalSlice {
  const FailMeetingCancellationSlice();

  @override
  String get name => 'fail_meeting_cancellation';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final processor = createSagaManager<FailedCalendarDeletionState, FailCancellationCommand, NoMetadata, NoMetadata>(
      saga: calendarDeletionFailureTranslatorSaga,
      actionPublisher: createFailCancellationPublisher(services.eventStore),
    );
    registrar.subscribe(
      EventSubscription(
        name: 'automation:fail_meeting_cancellation',
        eventTypes: {CalendarEventDeletionFailedEvent},
        handle: (stored) => failMeetingCancellationHandler(processor, stored),
      ),
    );
  }
}
