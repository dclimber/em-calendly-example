import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/corporate_calendar/api.dart';
import '../../platform/event_store/event_store.dart';
import 'record_busy_times/command.dart';
import 'reported_free_busy/state.dart';
import 'reported_free_busy/view.dart';

/// Handles one `free_busy_reported` event: folds it into the reported free/busy data, then runs the processor on it.
///
/// Delivery is at least once. The decider accepts every command, so a redelivered event records the busy intervals
/// again (see the lifecycle gaps in `record_busy_times/decider.dart`).
Future<void> recordHostBusyTimesHandler(
  SagaManager<ReportedFreeBusyState, RecordBusyTimesCommand, NoMetadata, NoMetadata> processor,
  StoredEvent stored,
) async {
  final reported = reportedFreeBusyView.evolve(
    reportedFreeBusyView.initialState,
    stored.event as CorporateCalendarEvent,
  );
  // The view yields a state for every `free_busy_reported` event, so this check only narrows the type.
  if (reported == null) return;
  await processor.handle(reported).toList();
}
