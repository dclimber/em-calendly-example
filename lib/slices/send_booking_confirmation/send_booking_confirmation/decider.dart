import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

/// The decider of the `meeting` aggregate for `send_booking_confirmation`.
///
/// The model gives the transition `send_booking_confirmation` from `confirmed` only, and it leaves the state
/// `confirmed`. A repeat is refused here (see [BookingConfirmationAlreadySentError]), so the event is emitted once.
final sendBookingConfirmationDecider =
    Decider<SendBookingConfirmationCommand, SendBookingConfirmationState, MeetingsEvent>(
      initialState: const SendBookingConfirmationState(),
      decide: (command, state) async* {
        if (state.lifecycle != MeetingLifecycleState.confirmed) throw const MeetingNotConfirmedError();
        if (state.bookingConfirmationSent) throw const BookingConfirmationAlreadySentError();
        yield BookingConfirmationSentEvent(meetingId: command.meetingId, participants: command.participants);
      },
      evolve: (state, event) => switch (event) {
        MeetingSlotReservedEvent() => SendBookingConfirmationState(
          lifecycle: MeetingLifecycleState.pendingCalendar,
          bookingConfirmationSent: state.bookingConfirmationSent,
        ),
        MeetingConfirmedEvent() => SendBookingConfirmationState(
          lifecycle: MeetingLifecycleState.confirmed,
          bookingConfirmationSent: state.bookingConfirmationSent,
        ),
        MeetingBookingFailedEvent() => SendBookingConfirmationState(
          lifecycle: MeetingLifecycleState.bookingFailed,
          bookingConfirmationSent: state.bookingConfirmationSent,
        ),
        BookingConfirmationSentEvent() => SendBookingConfirmationState(
          lifecycle: state.lifecycle,
          bookingConfirmationSent: true,
        ),
        _ => state,
      },
    );
