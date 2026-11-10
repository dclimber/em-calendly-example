import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

/// The decider of the `meeting` aggregate for `complete_cancellation`.
///
/// The model gives the transition `complete_cancellation` from `canceling` only, and it leaves the state in `canceled`.
/// Every event that enters or keeps the lifecycle is folded here, so the decider knows the state of the meeting when the
/// calendar event is deleted.
final completeCancellationDecider = Decider<CompleteCancellationCommand, CompleteCancellationState, MeetingsEvent>(
  initialState: const CompleteCancellationState(),
  decide: (command, state) async* {
    if (state.lifecycle != MeetingLifecycleState.canceling) throw const MeetingNotCancelingError();
    yield MeetingCanceledEvent(meetingId: command.meetingId);
  },
  evolve: (state, event) => switch (event) {
    MeetingSlotReservedEvent() => const CompleteCancellationState(lifecycle: MeetingLifecycleState.pendingCalendar),
    MeetingConfirmedEvent() ||
    MeetingRescheduledEvent() ||
    MeetingRescheduleFailedEvent() ||
    MeetingMovedInCalendarEvent() ||
    MeetingCancellationFailedEvent() => const CompleteCancellationState(lifecycle: MeetingLifecycleState.confirmed),
    MeetingBookingFailedEvent() => const CompleteCancellationState(lifecycle: MeetingLifecycleState.bookingFailed),
    MeetingRescheduleRequestedEvent() => const CompleteCancellationState(lifecycle: MeetingLifecycleState.rescheduling),
    MeetingCancellationRequestedEvent() => const CompleteCancellationState(lifecycle: MeetingLifecycleState.canceling),
    MeetingCanceledEvent() => const CompleteCancellationState(lifecycle: MeetingLifecycleState.canceled),
    MeetingCompletedEvent() => const CompleteCancellationState(lifecycle: MeetingLifecycleState.completed),
    _ => state,
  },
);
