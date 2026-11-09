import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/corporate_calendar/api.dart';
import '../../platform/event_store/event_store.dart';
import 'failed_calendar_access/state.dart';
import 'failed_calendar_access/view.dart';
import 'record_connection_failure/command.dart';

/// Handles one `calendar_access_failed` event: folds it into the failed access, then runs the processor on it.
///
/// Delivery is at least once. The decider accepts every command, so a redelivered event records the failure again
/// (see the lifecycle gaps in `record_connection_failure/decider.dart`).
Future<void> recordConnectionFailureHandler(
  SagaManager<FailedCalendarAccessState, RecordConnectionFailureCommand, NoMetadata, NoMetadata> processor,
  StoredEvent stored,
) async {
  final failed = failedCalendarAccessView.evolve(
    failedCalendarAccessView.initialState,
    stored.event as CorporateCalendarEvent,
  );
  // The view yields a state for every `calendar_access_failed` event, so this check only narrows the type.
  if (failed == null) return;
  await processor.handle(failed).toList();
}
