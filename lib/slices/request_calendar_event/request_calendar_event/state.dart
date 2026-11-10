import '../../../bounded_contexts/meetings/api.dart';

/// The meeting as the decider folds it: its lifecycle state, and whether its calendar event was already requested.
final class RequestCalendarEventState {
  const RequestCalendarEventState({this.lifecycle, this.calendarEventRequested = false});

  /// Null before the meeting is reserved.
  final MeetingLifecycleState? lifecycle;
  final bool calendarEventRequested;

  @override
  bool operator ==(Object other) =>
      other is RequestCalendarEventState &&
      other.lifecycle == lifecycle &&
      other.calendarEventRequested == calendarEventRequested;

  @override
  int get hashCode => Object.hash(lifecycle, calendarEventRequested);

  @override
  String toString() =>
      'RequestCalendarEventState(lifecycle: $lifecycle, calendarEventRequested: $calendarEventRequested)';
}
