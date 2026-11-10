import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

/// The decider of the `meeting` aggregate for `complete_meeting`. The model's transition `complete` has the source state
/// `confirmed` only, so any other lifecycle state is refused.
final completeMeetingDecider = Decider<CompleteMeetingCommand, CompleteMeetingState, MeetingsEvent>(
  initialState: const CompleteMeetingState(),
  decide: (command, state) async* {
    if (state.lifecycle != MeetingLifecycleState.confirmed) throw const MeetingNotConfirmedError();
    yield MeetingCompletedEvent(meetingId: command.meetingId);
  },
  evolve: (state, event) => switch (event) {
    MeetingSlotReservedEvent() => const CompleteMeetingState(lifecycle: MeetingLifecycleState.pendingCalendar),
    MeetingConfirmedEvent() => const CompleteMeetingState(lifecycle: MeetingLifecycleState.confirmed),
    MeetingBookingFailedEvent() => const CompleteMeetingState(lifecycle: MeetingLifecycleState.bookingFailed),
    MeetingRescheduleRequestedEvent() => const CompleteMeetingState(lifecycle: MeetingLifecycleState.rescheduling),
    MeetingRescheduledEvent() => const CompleteMeetingState(lifecycle: MeetingLifecycleState.confirmed),
    MeetingRescheduleFailedEvent() => const CompleteMeetingState(lifecycle: MeetingLifecycleState.confirmed),
    MeetingCancellationRequestedEvent() => const CompleteMeetingState(lifecycle: MeetingLifecycleState.canceling),
    MeetingCancellationFailedEvent() => const CompleteMeetingState(lifecycle: MeetingLifecycleState.confirmed),
    MeetingCanceledEvent() => const CompleteMeetingState(lifecycle: MeetingLifecycleState.canceled),
    MeetingCompletedEvent() => const CompleteMeetingState(lifecycle: MeetingLifecycleState.completed),
    _ => state,
  },
);
