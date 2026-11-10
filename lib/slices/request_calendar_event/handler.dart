import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/meetings/api.dart';
import '../../platform/event_store/event_store.dart';
import 'request_calendar_event/command.dart';
import 'request_calendar_event/errors.dart';
import 'reservations_awaiting_calendar_event/repository.dart';
import 'reservations_awaiting_calendar_event/state.dart';
import 'reservations_awaiting_calendar_event/view.dart';

/// Handles one `meeting_slot_reserved`, `booking_slot_verified`, or `calendar_event_requested` event: folds it into the
/// to-do list, then runs the processor on the item that it leaves open.
///
/// Delivery is at least once. A redelivered `meeting_slot_reserved` reopens an unverified item, and a repeated request
/// is refused by the decider, which the handler ignores.
Future<void> requestCalendarEventHandler(
  SagaManager<ReservationAwaitingCalendarEventState, RequestCalendarEventCommand, NoMetadata, NoMetadata> processor,
  ReservationsAwaitingCalendarEventRepository repository,
  StoredEvent stored,
) async {
  final view = createMaterializedView<ReservationAwaitingCalendarEventState?, StoredEvent, NoMetadata>(
    view: reservationsAwaitingCalendarEventView.mapLeftOnEvent<StoredEvent>((s) => s.event as MeetingsEvent),
    viewStateRepository: repository,
  );
  final item = await view.handle(stored);
  // The view closes the item for the requested event, which opens no item.
  if (item == null) return;
  try {
    await processor.handle(item).toList();
  } on RequestCalendarEventError {
    // The calendar event was already requested, or the meeting left pending_calendar: nothing to do.
  }
}
