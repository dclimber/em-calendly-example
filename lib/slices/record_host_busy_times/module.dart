import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/corporate_calendar/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/event_streaming/event_subscription.dart';
import 'handler.dart';
import 'publisher.dart';
import 'record_busy_times/command.dart';
import 'reported_free_busy/state.dart';
import 'saga.dart';

/// The automation `record_host_busy_times`, a translation of the calendar system's `free_busy_reported` into the
/// host's busy intervals. No other calendar content crosses this boundary.
final class RecordHostBusyTimesSlice implements VerticalSlice {
  const RecordHostBusyTimesSlice();

  @override
  String get name => 'record_host_busy_times';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final processor = createSagaManager<ReportedFreeBusyState, RecordBusyTimesCommand, NoMetadata, NoMetadata>(
      saga: freeBusyTranslatorSaga,
      actionPublisher: createRecordBusyTimesPublisher(services.eventStore),
    );
    registrar.subscribe(
      EventSubscription(
        name: 'automation:record_host_busy_times',
        eventTypes: {FreeBusyReportedEvent},
        handle: (stored) => recordHostBusyTimesHandler(processor, stored),
      ),
    );
  }
}
