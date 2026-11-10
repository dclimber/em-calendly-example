import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'state.dart';

/// The pure view `reservations_awaiting_calendar_event`. A held slot is opened by `meeting_slot_reserved` (unverified),
/// marked verified by `booking_slot_verified`, and leaves the list when `calendar_event_requested` arrives (a null
/// state deletes the item).
final reservationsAwaitingCalendarEventView = View<ReservationAwaitingCalendarEventState?, MeetingsEvent>(
  initialState: null,
  evolve: (state, event) => switch (event) {
    MeetingSlotReservedEvent() => ReservationAwaitingCalendarEventState(
      meetingId: event.meetingId,
      hostId: event.hostId,
      meetingTitle: event.meetingTitle,
      meetingLocation: event.meetingLocation,
      slotStart: event.slotStart,
      slotEnd: event.slotEnd,
      participants: event.participants,
    ),
    BookingSlotVerifiedEvent() => state?.copyWith(verified: true),
    CalendarEventRequestedEvent() => null,
    _ => state,
  },
);
