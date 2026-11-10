import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/corporate_calendar/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/event_streaming/event_subscription.dart';
import 'failed_calendar_updates/state.dart';
import 'fail_reschedule/command.dart';
import 'handler.dart';
import 'publisher.dart';
import 'saga.dart';

/// The automation `fail_meeting_reschedule`: records that a reschedule failed when the calendar system gives a negative
/// answer for a meeting that is rescheduling. The meeting keeps its original time and is confirmed again.
final class FailMeetingRescheduleSlice implements VerticalSlice {
  const FailMeetingRescheduleSlice();

  @override
  String get name => 'fail_meeting_reschedule';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final processor = createSagaManager<FailedCalendarUpdateState, FailRescheduleCommand, NoMetadata, NoMetadata>(
      saga: calendarUpdateFailureTranslatorSaga,
      actionPublisher: createFailRescheduePublisher(services.eventStore),
    );
    registrar.subscribe(
      EventSubscription(
        name: 'automation:fail_meeting_reschedule',
        eventTypes: {CalendarEventUpdateFailedEvent, HostSlotFoundBusyEvent, AvailabilityCheckFailedEvent},
        handle: (stored) => failMeetingRescheduleHandler(processor, stored),
      ),
    );
  }
}
