import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

/// The decider of the `meeting` aggregate for `fail_reschedule`.
///
/// The model gives the transition `fail_reschedule` from `rescheduling` only, to `confirmed`: the meeting keeps its
/// original time. Any other state is refused with [MeetingNotReschedulingError], so a repeated or late answer emits
/// nothing.
final failRescheduleDecider = Decider<FailRescheduleCommand, FailRescheduleState, MeetingsEvent>(
  initialState: const FailRescheduleState(),
  decide: (command, state) async* {
    if (state.lifecycle != MeetingLifecycleState.rescheduling) throw const MeetingNotReschedulingError();
    yield MeetingRescheduleFailedEvent(meetingId: command.meetingId, failureReason: command.failureReason);
  },
  evolve: (state, event) => switch (event) {
    MeetingSlotReservedEvent() => const FailRescheduleState(lifecycle: MeetingLifecycleState.pendingCalendar),
    MeetingConfirmedEvent() ||
    MeetingRescheduledEvent() ||
    MeetingRescheduleFailedEvent() ||
    MeetingMovedInCalendarEvent() => const FailRescheduleState(lifecycle: MeetingLifecycleState.confirmed),
    MeetingBookingFailedEvent() => const FailRescheduleState(lifecycle: MeetingLifecycleState.bookingFailed),
    MeetingRescheduleRequestedEvent() => const FailRescheduleState(lifecycle: MeetingLifecycleState.rescheduling),
    MeetingCancellationRequestedEvent() => const FailRescheduleState(lifecycle: MeetingLifecycleState.canceling),
    MeetingCanceledEvent() => const FailRescheduleState(lifecycle: MeetingLifecycleState.canceled),
    MeetingCompletedEvent() => const FailRescheduleState(lifecycle: MeetingLifecycleState.completed),
    _ => state,
  },
);
