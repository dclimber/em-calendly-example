import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

/// The decider of the `meeting` aggregate for `fail_cancellation`.
///
/// The model gives the transition `fail_cancellation` from `canceling` only, to `confirmed`: the meeting stays confirmed.
/// Any other state is refused with [MeetingNotCancelingError], so a repeated or late answer emits nothing.
final failCancellationDecider = Decider<FailCancellationCommand, FailCancellationState, MeetingsEvent>(
  initialState: const FailCancellationState(),
  decide: (command, state) async* {
    if (state.lifecycle != MeetingLifecycleState.canceling) throw const MeetingNotCancelingError();
    yield MeetingCancellationFailedEvent(meetingId: command.meetingId, failureReason: command.failureReason);
  },
  evolve: (state, event) => switch (event) {
    MeetingSlotReservedEvent() => const FailCancellationState(lifecycle: MeetingLifecycleState.pendingCalendar),
    MeetingConfirmedEvent() ||
    MeetingRescheduledEvent() ||
    MeetingRescheduleFailedEvent() ||
    MeetingMovedInCalendarEvent() ||
    MeetingCancellationFailedEvent() => const FailCancellationState(lifecycle: MeetingLifecycleState.confirmed),
    MeetingBookingFailedEvent() => const FailCancellationState(lifecycle: MeetingLifecycleState.bookingFailed),
    MeetingRescheduleRequestedEvent() => const FailCancellationState(lifecycle: MeetingLifecycleState.rescheduling),
    MeetingCancellationRequestedEvent() => const FailCancellationState(lifecycle: MeetingLifecycleState.canceling),
    MeetingCanceledEvent() => const FailCancellationState(lifecycle: MeetingLifecycleState.canceled),
    MeetingCompletedEvent() => const FailCancellationState(lifecycle: MeetingLifecycleState.completed),
    _ => state,
  },
);
