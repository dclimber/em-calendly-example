import 'package:fmodel/fmodel.dart';

import '../../platform/event_store/event_store.dart';
import 'complete_cancellation/command.dart';
import 'complete_cancellation/errors.dart';
import 'deleted_calendar_events/state.dart';
import 'deleted_calendar_events/view.dart';

/// Handles one `calendar_event_deleted` event: lists its meeting in the view, then runs the processor on that item.
///
/// Delivery is at least once. A redelivered event for a meeting that already completed its cancellation is refused by the
/// decider, which the handler ignores.
Future<void> completeMeetingCancellationHandler(
  SagaManager<DeletedCalendarEventState, CompleteCancellationCommand, NoMetadata, NoMetadata> processor,
  StoredEvent stored,
) async {
  final item = deletedCalendarEventsView.evolve(deletedCalendarEventsView.initialState, stored.event);
  if (item == null) return;
  try {
    await processor.handle(item).toList();
  } on CompleteCancellationError {
    // The meeting is no longer canceling: nothing to complete.
  }
}
