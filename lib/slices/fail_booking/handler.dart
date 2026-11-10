import 'package:fmodel/fmodel.dart';

import '../../platform/event_store/event_store.dart';
import 'failed_calendar_events/state.dart';
import 'failed_calendar_events/view.dart';
import 'fail_booking/command.dart';
import 'fail_booking/errors.dart';

/// Handles one negative calendar answer: folds it into the failed-event view, then runs the processor on the item that
/// it lists.
///
/// Delivery is at least once. A redelivered answer lists the item again, and the decider then refuses the booking
/// failure because the meeting is no longer pending_calendar, which the handler ignores.
Future<void> failBookingHandler(
  SagaManager<FailedCalendarEventState, FailBookingCommand, NoMetadata, NoMetadata> processor,
  StoredEvent stored,
) async {
  final item = failedCalendarEventsView.evolve(failedCalendarEventsView.initialState, stored.event);
  if (item == null) return;
  try {
    await processor.handle(item).toList();
  } on FailBookingError {
    // The meeting is not pending_calendar: nothing to do.
  }
}
