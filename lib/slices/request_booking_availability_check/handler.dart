import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/meetings/api.dart';
import '../../platform/event_store/event_store.dart';
import 'request_booking_availability_check/command.dart';
import 'request_booking_availability_check/errors.dart';
import 'reservations_awaiting_live_check/repository.dart';
import 'reservations_awaiting_live_check/state.dart';
import 'reservations_awaiting_live_check/view.dart';

/// Handles one `meeting_slot_reserved` or `booking_availability_check_requested` event: folds it into the to-do list,
/// then runs the processor on the item that it leaves open.
///
/// Delivery is at least once. A redelivered `meeting_slot_reserved` reopens the item, and the decider then refuses the
/// repeated request, which the handler ignores.
Future<void> requestBookingAvailabilityCheckHandler(
  SagaManager<ReservationAwaitingLiveCheckState, RequestBookingAvailabilityCheckCommand, NoMetadata, NoMetadata>
  processor,
  ReservationsAwaitingLiveCheckRepository repository,
  StoredEvent stored,
) async {
  final view = createMaterializedView<ReservationAwaitingLiveCheckState?, StoredEvent, NoMetadata>(
    view: reservationsAwaitingLiveCheckView.mapLeftOnEvent<StoredEvent>((s) => s.event as MeetingsEvent),
    viewStateRepository: repository,
  );
  final item = await view.handle(stored);
  // The view closes the item only for the requested event, which opens no item.
  if (item == null) return;
  try {
    await processor.handle(item).toList();
  } on RequestBookingAvailabilityCheckError {
    // The check was already requested, or the meeting left pending_calendar: nothing to do.
  }
}
