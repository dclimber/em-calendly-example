import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/corporate_calendar/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/event_streaming/event_subscription.dart';
import 'handler.dart';
import 'publisher.dart';
import 'record_meeting_moved/command.dart';
import 'saga.dart';

/// The automation `apply_direct_calendar_move`: a translation of the calendar system's direct move. The calendar wins:
/// the meeting takes the moved times, while it is confirmed or rescheduling.
final class ApplyDirectCalendarMoveSlice implements VerticalSlice {
  const ApplyDirectCalendarMoveSlice();

  @override
  String get name => 'apply_direct_calendar_move';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final processor = createSagaManager<DirectMoveInput, RecordMeetingMovedCommand, NoMetadata, NoMetadata>(
      saga: directMoveTranslatorSaga,
      actionPublisher: createRecordMeetingMovedPublisher(services.eventStore),
    );
    registrar.subscribe(
      EventSubscription(
        name: 'automation:apply_direct_calendar_move',
        eventTypes: {CalendarEventMovedDirectlyEvent},
        handle: (stored) => recordMeetingMovedHandler(services.eventStore, processor, stored),
      ),
    );
  }
}
