import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

/// The decider of the `meeting` aggregate for `fail_booking`.
///
/// The model gives the transition `fail_booking` from `pending_calendar` only, to `booking_failed`. Any other state is
/// refused with [BookingNotPendingCalendarError], so a repeated or late answer emits nothing.
final failBookingDecider = Decider<FailBookingCommand, FailBookingState, MeetingsEvent>(
  initialState: const FailBookingState(),
  decide: (command, state) async* {
    if (state.lifecycle != MeetingLifecycleState.pendingCalendar) {
      throw const BookingNotPendingCalendarError();
    }
    yield MeetingBookingFailedEvent(meetingId: command.meetingId, failureReason: command.failureReason);
  },
  evolve: (state, event) => switch (event) {
    MeetingSlotReservedEvent() => const FailBookingState(lifecycle: MeetingLifecycleState.pendingCalendar),
    MeetingConfirmedEvent() => const FailBookingState(lifecycle: MeetingLifecycleState.confirmed),
    MeetingBookingFailedEvent() => const FailBookingState(lifecycle: MeetingLifecycleState.bookingFailed),
    _ => state,
  },
);
