import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/corporate_calendar/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/event_streaming/event_subscription.dart';
import 'failed_calendar_access/state.dart';
import 'handler.dart';
import 'publisher.dart';
import 'record_connection_failure/command.dart';
import 'saga.dart';

/// The automation `record_calendar_connection_failure`, a translation of the calendar system's `calendar_access_failed`
/// into the fact that the host's calendar connection failed.
final class RecordCalendarConnectionFailureSlice implements VerticalSlice {
  const RecordCalendarConnectionFailureSlice();

  @override
  String get name => 'record_calendar_connection_failure';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final processor =
        createSagaManager<FailedCalendarAccessState, RecordConnectionFailureCommand, NoMetadata, NoMetadata>(
          saga: connectionFailureTranslatorSaga,
          actionPublisher: createRecordConnectionFailurePublisher(services.eventStore),
        );
    registrar.subscribe(
      EventSubscription(
        name: 'automation:record_calendar_connection_failure',
        eventTypes: {CalendarAccessFailedEvent},
        handle: (stored) => recordConnectionFailureHandler(processor, stored),
      ),
    );
  }
}
