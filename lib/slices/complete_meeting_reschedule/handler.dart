import 'package:fmodel/fmodel.dart';

import '../../platform/event_store/event_store.dart';
import 'complete_reschedule/command.dart';
import 'complete_reschedule/errors.dart';
import 'updated_calendar_events/state.dart';
import 'updated_calendar_events/view.dart';

/// Handles one `calendar_event_updated` event: lists its meeting in the view, then runs the processor on that item.
///
/// Delivery is at least once. A redelivered event for a meeting that already completed its reschedule is refused by the
/// decider, which the handler ignores.
Future<void> completeMeetingRescheduleHandler(
  SagaManager<UpdatedCalendarEventState, CompleteRescheduleCommand, NoMetadata, NoMetadata> processor,
  StoredEvent stored,
) async {
  final item = updatedCalendarEventsView.evolve(updatedCalendarEventsView.initialState, stored.event);
  if (item == null) return;
  try {
    await processor.handle(item).toList();
  } on CompleteRescheduleError {
    // The meeting is no longer rescheduling: nothing to complete.
  }
}
