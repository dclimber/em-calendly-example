import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'state.dart';

/// The pure view `reservations_awaiting_live_check`: a held slot is listed from its `meeting_slot_reserved` event, and
/// leaves the list when its `booking_availability_check_requested` event arrives (a null state deletes the item).
final reservationsAwaitingLiveCheckView = View<ReservationAwaitingLiveCheckState?, MeetingsEvent>(
  initialState: null,
  evolve: (state, event) => switch (event) {
    MeetingSlotReservedEvent() => ReservationAwaitingLiveCheckState(
      meetingId: event.meetingId,
      hostId: event.hostId,
      slotStart: event.slotStart,
      slotEnd: event.slotEnd,
    ),
    BookingAvailabilityCheckRequestedEvent() => null,
    _ => state,
  },
);
