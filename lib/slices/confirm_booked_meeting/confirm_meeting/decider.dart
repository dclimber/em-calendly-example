import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

/// The decider of the `meeting` aggregate for `confirm_meeting`.
///
/// The model gives the transition `confirm` from `pending_calendar` only. Every event that enters or keeps
/// pending_calendar is folded here: the reservation, and the three events that the model's transitions leave in
/// pending_calendar. A terminal state (confirmed, booking_failed) is never left by these events.
final confirmMeetingDecider = Decider<ConfirmMeetingCommand, ConfirmMeetingState, MeetingsEvent>(
  initialState: const ConfirmMeetingState(),
  decide: (command, state) async* {
    if (state.lifecycle != MeetingLifecycleState.pendingCalendar) throw const MeetingNotAwaitingConfirmationError();
    yield MeetingConfirmedEvent(meetingId: command.meetingId, calendarEventId: command.calendarEventId);
  },
  evolve: (state, event) => switch (event) {
    MeetingSlotReservedEvent() => const ConfirmMeetingState(lifecycle: MeetingLifecycleState.pendingCalendar),
    BookingAvailabilityCheckRequestedEvent() || BookingSlotVerifiedEvent() || CalendarEventRequestedEvent() =>
      ConfirmMeetingState(lifecycle: state.lifecycle ?? MeetingLifecycleState.pendingCalendar),
    MeetingConfirmedEvent() => const ConfirmMeetingState(lifecycle: MeetingLifecycleState.confirmed),
    MeetingBookingFailedEvent() => const ConfirmMeetingState(lifecycle: MeetingLifecycleState.bookingFailed),
    _ => state,
  },
);
