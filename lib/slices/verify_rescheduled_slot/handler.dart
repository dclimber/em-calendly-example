import 'package:fmodel/fmodel.dart';

import '../../platform/event_store/event_store.dart';
import 'free_answers_for_reschedules/state.dart';
import 'free_answers_for_reschedules/view.dart';
import 'record_new_slot_verified/command.dart';
import 'record_new_slot_verified/errors.dart';

/// Handles one `host_slot_found_free` or `reschedule_availability_check_requested` event: folds it into the free-answer
/// view, then runs the processor on the item that it lists.
///
/// Delivery is at least once. A redelivered answer lists the item again, and the decider then refuses the repeated
/// verification, which the handler ignores.
Future<void> verifyRescheduledSlotHandler(
  SagaManager<FreeAnswerForRescheduleState, RecordNewSlotVerifiedCommand, NoMetadata, NoMetadata> processor,
  StoredEvent stored,
) async {
  final item = freeAnswersForReschedulesView.evolve(
    freeAnswersForReschedulesView.initialState,
    stored.event,
  );
  if (item == null) return;
  try {
    await processor.handle(item).toList();
  } on RecordNewSlotVerifiedError {
    // The meeting is not rescheduling, or the new slot was already verified: nothing to do.
  }
}
