import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/meetings/api.dart';
import 'state.dart';

/// The pure view of `booking_outcome`, one document per meeting. `meeting_slot_reserved` creates the document as
/// pending. `meeting_confirmed` sets it to confirmed. `meeting_booking_failed` sets it to failed and keeps the reason.
/// Events that arrive before the reservation change nothing.
final bookingOutcomeView = View<BookingOutcome?, MeetingsEvent>(
  initialState: null,
  evolve: (state, event) => switch (event) {
    MeetingSlotReservedEvent(
      :final meetingId,
      :final bookerId,
      :final meetingTypeId,
      :final meetingTitle,
      :final meetingLocation,
      :final slotStart,
      :final slotEnd,
    ) =>
      BookingOutcome(
        meetingId: meetingId,
        bookerId: bookerId,
        meetingTypeId: meetingTypeId,
        meetingTitle: meetingTitle,
        meetingLocation: meetingLocation,
        slotStart: slotStart,
        slotEnd: slotEnd,
        meetingStatus: BookingStatus.pending,
      ),
    MeetingConfirmedEvent() => state?.withStatus(BookingStatus.confirmed),
    MeetingBookingFailedEvent(:final failureReason) => state?.withStatus(
      BookingStatus.failed,
      failure: failureReason,
    ),
    _ => state,
  },
);
