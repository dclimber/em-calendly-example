import '../../platform/event_store/event_store.dart';
import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/corporate_calendar/api.dart';
import 'granted_calendar_access/state.dart';
import 'granted_calendar_access/view.dart';
import 'record_calendar_connected/command.dart';

/// Handles one `calendar_access_granted` event: folds it into the granted access, then runs the processor on it.
///
/// Delivery is at least once. The decider accepts every command, so a redelivered event records the connection again
/// (see the lifecycle gaps in `record_calendar_connected/decider.dart`).
Future<void> recordCalendarConnectedHandler(
  SagaManager<GrantedCalendarAccessState, RecordCalendarConnectedCommand, NoMetadata, NoMetadata> processor,
  StoredEvent stored,
) async {
  final granted = grantedCalendarAccessView.evolve(
    grantedCalendarAccessView.initialState,
    stored.event as CorporateCalendarEvent,
  );
  // The view yields a state for every `calendar_access_granted` event, so this check only narrows the type.
  if (granted == null) return;
  await processor.handle(granted).toList();
}
