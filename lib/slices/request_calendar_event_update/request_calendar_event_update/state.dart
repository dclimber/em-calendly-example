import '../../../bounded_contexts/meetings/api.dart';

/// The meeting as the decider folds it: its lifecycle state, and whether the calendar update of its current reschedule
/// request was already requested.
final class RequestCalendarEventUpdateState {
  const RequestCalendarEventUpdateState({this.lifecycle, this.calendarEventUpdateRequested = false});

  /// Null before the meeting is reserved.
  final MeetingLifecycleState? lifecycle;

  /// Reset by each `meeting_reschedule_requested`; a repeat for the same reschedule request is refused.
  final bool calendarEventUpdateRequested;

  @override
  bool operator ==(Object other) =>
      other is RequestCalendarEventUpdateState &&
      other.lifecycle == lifecycle &&
      other.calendarEventUpdateRequested == calendarEventUpdateRequested;

  @override
  int get hashCode => Object.hash(lifecycle, calendarEventUpdateRequested);

  @override
  String toString() =>
      'RequestCalendarEventUpdateState(lifecycle: $lifecycle, calendarEventUpdateRequested: $calendarEventUpdateRequested)';
}
