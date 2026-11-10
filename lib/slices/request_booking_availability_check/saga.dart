import 'package:fmodel/fmodel.dart';

import 'request_booking_availability_check/command.dart';
import 'reservations_awaiting_live_check/state.dart';

/// The processor `booking_check_requester`: each held slot that awaits a live check yields one
/// `request_booking_availability_check` command for its meeting, host, and slot.
final bookingCheckRequesterSaga = saga<ReservationAwaitingLiveCheckState, RequestBookingAvailabilityCheckCommand>(
  (item) async* {
    yield RequestBookingAvailabilityCheckCommand(
      meetingId: item.meetingId,
      hostId: item.hostId,
      slotStart: item.slotStart,
      slotEnd: item.slotEnd,
    );
  },
);
