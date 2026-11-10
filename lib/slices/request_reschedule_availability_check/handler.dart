import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/meetings/api.dart';
import '../../platform/event_store/event_store.dart';
import 'request_reschedule_availability_check/command.dart';
import 'request_reschedule_availability_check/errors.dart';
import 'reschedules_awaiting_live_check/repository.dart';
import 'reschedules_awaiting_live_check/state.dart';
import 'reschedules_awaiting_live_check/view.dart';

/// Handles one `meeting_reschedule_requested`, `reschedule_availability_check_requested`, `meeting_moved_in_calendar`,
/// or `meeting_canceled` event: folds it into the to-do list, then runs the processor on the item that it leaves open.
///
/// Delivery is at least once. A redelivered `meeting_reschedule_requested` reopens the item, and the decider then
/// refuses the repeated request, which the handler ignores.
Future<void> requestRescheduleAvailabilityCheckHandler(
  SagaManager<RescheduleAwaitingLiveCheckState, RequestRescheduleAvailabilityCheckCommand, NoMetadata, NoMetadata>
  processor,
  ReschedulesAwaitingLiveCheckRepository repository,
  StoredEvent stored,
) async {
  final view = createMaterializedView<RescheduleAwaitingLiveCheckState?, StoredEvent, NoMetadata>(
    view: reschedulesAwaitingLiveCheckView.mapLeftOnEvent<StoredEvent>((s) => s.event as MeetingsEvent),
    viewStateRepository: repository,
  );
  final item = await view.handle(stored);
  // The view closes the item for every event except `meeting_reschedule_requested`, which is the only one that opens it.
  if (item == null) return;
  try {
    await processor.handle(item).toList();
  } on RequestRescheduleAvailabilityCheckError {
    // The check was already requested, or the meeting left rescheduling: nothing to do.
  }
}
