import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/meetings/api.dart';
import '../../platform/event_store/event_store.dart';
import 'request_calendar_event_update/command.dart';
import 'request_calendar_event_update/errors.dart';
import 'reschedules_awaiting_calendar_update/repository.dart';
import 'reschedules_awaiting_calendar_update/state.dart';
import 'reschedules_awaiting_calendar_update/view.dart';

/// Handles one `meeting_reschedule_requested`, `new_slot_verified`, `calendar_event_update_requested`,
/// `meeting_moved_in_calendar`, or `meeting_canceled` event: folds it into the to-do list, then runs the processor on
/// the item that it leaves open.
///
/// Delivery is at least once. A redelivered reschedule keeps its verification, and a repeated request is refused by
/// the decider, which the handler ignores.
Future<void> requestCalendarEventUpdateHandler(
  SagaManager<ReschedulesAwaitingCalendarUpdateState, RequestCalendarEventUpdateCommand, NoMetadata, NoMetadata>
  processor,
  ReschedulesAwaitingCalendarUpdateRepository repository,
  StoredEvent stored,
) async {
  final view = createMaterializedView<ReschedulesAwaitingCalendarUpdateState?, StoredEvent, NoMetadata>(
    view: reschedulesAwaitingCalendarUpdateView.mapLeftOnEvent<StoredEvent>((s) => s.event as MeetingsEvent),
    viewStateRepository: repository,
  );
  final item = await view.handle(stored);
  // The view closes the item for the events that end the update, which open no item.
  if (item == null) return;
  try {
    await processor.handle(item).toList();
  } on RequestCalendarEventUpdateError {
    // The calendar update was already requested, or the meeting left rescheduling: nothing to do.
  }
}
