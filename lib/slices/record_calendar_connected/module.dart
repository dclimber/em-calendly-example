import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/corporate_calendar/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/event_streaming/event_subscription.dart';
import 'granted_calendar_access/state.dart';
import 'handler.dart';
import 'publisher.dart';
import 'record_calendar_connected/command.dart';
import 'saga.dart';

/// The automation `record_calendar_connected`, a translation of the calendar system's `calendar_access_granted`
/// into the fact that the host's calendar is connected.
final class RecordCalendarConnectedSlice implements VerticalSlice {
  const RecordCalendarConnectedSlice();

  @override
  String get name => 'record_calendar_connected';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final processor =
        createSagaManager<GrantedCalendarAccessState, RecordCalendarConnectedCommand, NoMetadata, NoMetadata>(
          saga: connectionTranslatorSaga,
          actionPublisher: createRecordCalendarConnectedPublisher(services.eventStore),
        );
    registrar.subscribe(
      EventSubscription(
        name: 'automation:record_calendar_connected',
        eventTypes: {CalendarAccessGrantedEvent},
        handle: (stored) => recordCalendarConnectedHandler(processor, stored),
      ),
    );
  }
}
