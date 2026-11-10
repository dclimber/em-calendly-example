import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'state.dart';

/// The pure view `confirmations_to_send`. A reserved meeting opens an item (not ready), `meeting_confirmed` marks it
/// ready, and `booking_confirmation_sent` closes it (a null state deletes the item).
final confirmationsToSendView = View<ConfirmationToSendState?, MeetingsEvent>(
  initialState: null,
  evolve: (state, event) => switch (event) {
    // A redelivered reservation keeps the ready flag of an item that the confirmation already made ready.
    MeetingSlotReservedEvent() => ConfirmationToSendState(
      meetingId: event.meetingId,
      meetingTitle: event.meetingTitle,
      meetingLocation: event.meetingLocation,
      slotStart: event.slotStart,
      slotEnd: event.slotEnd,
      participants: event.participants,
      ready: state?.ready ?? false,
    ),
    MeetingConfirmedEvent() => state?.copyWith(ready: true),
    BookingConfirmationSentEvent() => null,
    _ => state,
  },
);
