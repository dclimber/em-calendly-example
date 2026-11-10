import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

/// The decider of the `meeting` aggregate for `complete_reschedule`.
///
/// The model gives the transition `complete_reschedule` from `rescheduling` only, and it leaves the state in
/// `confirmed`. Every event that enters or keeps the lifecycle is folded here, so the decider knows the state of the
/// meeting when the calendar event moves.
final completeRescheduleDecider = Decider<CompleteRescheduleCommand, CompleteRescheduleState, MeetingsEvent>(
  initialState: const CompleteRescheduleState(),
  decide: (command, state) async* {
    if (state.lifecycle != MeetingLifecycleState.rescheduling) throw const MeetingNotReschedulingError();
    yield MeetingRescheduledEvent(meetingId: command.meetingId);
  },
  evolve: (state, event) => switch (event) {
    MeetingSlotReservedEvent() => const CompleteRescheduleState(lifecycle: MeetingLifecycleState.pendingCalendar),
    MeetingConfirmedEvent() ||
    MeetingRescheduledEvent() ||
    MeetingRescheduleFailedEvent() ||
    MeetingMovedInCalendarEvent() => const CompleteRescheduleState(lifecycle: MeetingLifecycleState.confirmed),
    MeetingBookingFailedEvent() => const CompleteRescheduleState(lifecycle: MeetingLifecycleState.bookingFailed),
    MeetingRescheduleRequestedEvent() => const CompleteRescheduleState(lifecycle: MeetingLifecycleState.rescheduling),
    MeetingCancellationRequestedEvent() => const CompleteRescheduleState(lifecycle: MeetingLifecycleState.canceling),
    MeetingCanceledEvent() => const CompleteRescheduleState(lifecycle: MeetingLifecycleState.canceled),
    MeetingCompletedEvent() => const CompleteRescheduleState(lifecycle: MeetingLifecycleState.completed),
    _ => state,
  },
);
