import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/meetings/api.dart';
import '../../platform/event_store/event_store.dart';
import 'cancellations_awaiting_calendar_deletion/repository.dart';
import 'cancellations_awaiting_calendar_deletion/state.dart';
import 'cancellations_awaiting_calendar_deletion/view.dart';
import 'request_calendar_event_deletion/command.dart';
import 'request_calendar_event_deletion/errors.dart';

/// Handles one `meeting_cancellation_requested`, `calendar_event_deletion_requested`, or `meeting_canceled` event: folds
/// it into the to-do list, then runs the processor on the item that it leaves open.
///
/// Delivery is at least once. A repeated request is refused by the decider, which the handler ignores.
Future<void> requestCalendarEventDeletionHandler(
  SagaManager<CancellationAwaitingCalendarDeletionState, RequestCalendarEventDeletionCommand, NoMetadata, NoMetadata>
  processor,
  CancellationsAwaitingCalendarDeletionRepository repository,
  StoredEvent stored,
) async {
  final view = createMaterializedView<CancellationAwaitingCalendarDeletionState?, StoredEvent, NoMetadata>(
    view: cancellationsAwaitingCalendarDeletionView.mapLeftOnEvent<StoredEvent>((s) => s.event as MeetingsEvent),
    viewStateRepository: repository,
  );
  final item = await view.handle(stored);
  // The view closes the item for the deletion or the direct cancellation, which opens no item.
  if (item == null) return;
  try {
    await processor.handle(item).toList();
  } on RequestCalendarEventDeletionError {
    // The deletion was already requested, or the meeting left canceling: nothing to do.
  }
}
