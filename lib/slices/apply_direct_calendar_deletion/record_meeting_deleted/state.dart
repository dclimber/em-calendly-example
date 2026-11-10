import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';

/// The meeting as the decider and the processor fold it: only its lifecycle state matters to a direct deletion.
final class RecordMeetingDeletedState {
  const RecordMeetingDeletedState({this.lifecycle});

  /// Null before the meeting is reserved.
  final MeetingLifecycleState? lifecycle;

  @override
  bool operator ==(Object other) => other is RecordMeetingDeletedState && other.lifecycle == lifecycle;

  @override
  int get hashCode => lifecycle.hashCode;

  @override
  String toString() => 'RecordMeetingDeletedState(lifecycle: $lifecycle)';
}

/// Folds every `meeting` event that changes or keeps the lifecycle. Shared by the decider and the processor history.
final meetingLifecycleView = View<RecordMeetingDeletedState, MeetingsEvent>(
  initialState: const RecordMeetingDeletedState(),
  evolve: (state, event) => switch (event) {
    MeetingSlotReservedEvent() => const RecordMeetingDeletedState(lifecycle: MeetingLifecycleState.pendingCalendar),
    MeetingConfirmedEvent() ||
    MeetingRescheduledEvent() ||
    MeetingRescheduleFailedEvent() ||
    MeetingMovedInCalendarEvent() => const RecordMeetingDeletedState(lifecycle: MeetingLifecycleState.confirmed),
    MeetingBookingFailedEvent() => const RecordMeetingDeletedState(lifecycle: MeetingLifecycleState.bookingFailed),
    MeetingRescheduleRequestedEvent() => const RecordMeetingDeletedState(lifecycle: MeetingLifecycleState.rescheduling),
    MeetingCancellationRequestedEvent() => const RecordMeetingDeletedState(lifecycle: MeetingLifecycleState.canceling),
    MeetingCanceledEvent() => const RecordMeetingDeletedState(lifecycle: MeetingLifecycleState.canceled),
    MeetingCompletedEvent() => const RecordMeetingDeletedState(lifecycle: MeetingLifecycleState.completed),
    _ => state,
  },
);
