import 'package:fmodel/fmodel.dart';

import '../../platform/event_store/event_store.dart';
import 'failed_calendar_updates/state.dart';
import 'failed_calendar_updates/view.dart';
import 'fail_reschedule/command.dart';
import 'fail_reschedule/errors.dart';

/// Handles one negative calendar answer about a reschedule: folds it into the failed-update view, then runs the processor
/// on the item that it lists.
///
/// Delivery is at least once. A redelivered answer lists the item again, and the decider then refuses the failure because
/// the meeting is no longer rescheduling, which the handler ignores.
Future<void> failMeetingRescheduleHandler(
  SagaManager<FailedCalendarUpdateState, FailRescheduleCommand, NoMetadata, NoMetadata> processor,
  StoredEvent stored,
) async {
  final item = failedCalendarUpdatesView.evolve(failedCalendarUpdatesView.initialState, stored.event);
  if (item == null) return;
  try {
    await processor.handle(item).toList();
  } on FailRescheduleError {
    // The meeting is not rescheduling: nothing to fail.
  }
}
