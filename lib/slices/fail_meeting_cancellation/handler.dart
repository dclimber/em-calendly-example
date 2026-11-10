import 'package:fmodel/fmodel.dart';

import '../../platform/event_store/event_store.dart';
import 'fail_cancellation/command.dart';
import 'fail_cancellation/errors.dart';
import 'failed_calendar_deletions/state.dart';
import 'failed_calendar_deletions/view.dart';

/// Handles one `calendar_event_deletion_failed` answer: folds it into the failed-deletions view, then runs the processor
/// on the item that it lists.
///
/// Delivery is at least once. A redelivered answer lists the item again, and the decider then refuses the failure because
/// the meeting is no longer canceling, which the handler ignores.
Future<void> failMeetingCancellationHandler(
  SagaManager<FailedCalendarDeletionState, FailCancellationCommand, NoMetadata, NoMetadata> processor,
  StoredEvent stored,
) async {
  final item = failedCalendarDeletionsView.evolve(failedCalendarDeletionsView.initialState, stored.event);
  if (item == null) return;
  try {
    await processor.handle(item).toList();
  } on FailCancellationError {
    // The meeting is not canceling: nothing to fail.
  }
}
