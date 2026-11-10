import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';

/// The meeting as the decider and the processor fold it: only its lifecycle state matters to a direct move.
final class RecordMeetingMovedState {
  const RecordMeetingMovedState({this.lifecycle});

  /// Null before the meeting is reserved.
  final MeetingLifecycleState? lifecycle;

  @override
  bool operator ==(Object other) => other is RecordMeetingMovedState && other.lifecycle == lifecycle;

  @override
  int get hashCode => lifecycle.hashCode;

  @override
  String toString() => 'RecordMeetingMovedState(lifecycle: $lifecycle)';
}

/// Folds every `meeting` event that changes or keeps the lifecycle. Shared by the decider and the processor history.
final meetingLifecycleView = View<RecordMeetingMovedState, MeetingsEvent>(
  initialState: const RecordMeetingMovedState(),
  evolve: (state, event) => switch (event) {
    MeetingSlotReservedEvent() => const RecordMeetingMovedState(lifecycle: MeetingLifecycleState.pendingCalendar),
    MeetingConfirmedEvent() ||
    MeetingRescheduledEvent() ||
    MeetingRescheduleFailedEvent() ||
    MeetingMovedInCalendarEvent() => const RecordMeetingMovedState(lifecycle: MeetingLifecycleState.confirmed),
    MeetingBookingFailedEvent() => const RecordMeetingMovedState(lifecycle: MeetingLifecycleState.bookingFailed),
    MeetingRescheduleRequestedEvent() => const RecordMeetingMovedState(lifecycle: MeetingLifecycleState.rescheduling),
    MeetingCancellationRequestedEvent() => const RecordMeetingMovedState(lifecycle: MeetingLifecycleState.canceling),
    MeetingCanceledEvent() => const RecordMeetingMovedState(lifecycle: MeetingLifecycleState.canceled),
    MeetingCompletedEvent() => const RecordMeetingMovedState(lifecycle: MeetingLifecycleState.completed),
    _ => state,
  },
);
