import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/corporate_calendar/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/event_streaming/event_subscription.dart';
import 'handler.dart';
import 'publisher.dart';
import 'record_meeting_deleted/command.dart';
import 'saga.dart';

/// The automation `apply_direct_calendar_deletion`: a translation of the calendar system's direct deletion. The calendar
/// wins: the meeting is canceled while it is confirmed, rescheduling, or canceling.
final class ApplyDirectCalendarDeletionSlice implements VerticalSlice {
  const ApplyDirectCalendarDeletionSlice();

  @override
  String get name => 'apply_direct_calendar_deletion';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final processor = createSagaManager<DirectDeletionInput, RecordMeetingDeletedCommand, NoMetadata, NoMetadata>(
      saga: directDeletionTranslatorSaga,
      actionPublisher: createRecordMeetingDeletedPublisher(services.eventStore),
    );
    registrar.subscribe(
      EventSubscription(
        name: 'automation:apply_direct_calendar_deletion',
        eventTypes: {CalendarEventDeletedDirectlyEvent},
        handle: (stored) => recordMeetingDeletedHandler(services.eventStore, processor, stored),
      ),
    );
  }
}
