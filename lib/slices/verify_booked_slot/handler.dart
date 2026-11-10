import 'package:fmodel/fmodel.dart';

import '../../platform/event_store/event_store.dart';
import 'free_answers_for_bookings/state.dart';
import 'free_answers_for_bookings/view.dart';
import 'record_booking_slot_verified/command.dart';
import 'record_booking_slot_verified/errors.dart';

/// Handles one `host_slot_found_free` or `booking_availability_check_requested` event: folds it into the free-answer
/// view, then runs the processor on the item that it lists.
///
/// Delivery is at least once. A redelivered answer lists the item again, and the decider then refuses the repeated
/// verification, which the handler ignores.
Future<void> verifyBookedSlotHandler(
  SagaManager<FreeAnswerForBookingState, RecordBookingSlotVerifiedCommand, NoMetadata, NoMetadata> processor,
  StoredEvent stored,
) async {
  final item = freeAnswersForBookingsView.evolve(
    freeAnswersForBookingsView.initialState,
    stored.event,
  );
  if (item == null) return;
  try {
    await processor.handle(item).toList();
  } on RecordBookingSlotVerifiedError {
    // The meeting left pending_calendar, or the slot was already verified: nothing to do.
  }
}
