import '../../../bounded_contexts/meetings/api.dart';

/// The meeting as the decider folds it: its lifecycle state, and whether the calendar event of the current cancellation
/// was already requested for deletion.
///
/// Only the events that enter or leave `canceling` change the lifecycle here: `request_cancellation` enters it,
/// `fail_cancellation` and `complete_cancellation` leave it, and `record_direct_deletion` ends it. A new cancellation
/// resets [calendarDeletionRequested].
final class RequestCalendarEventDeletionState {
  const RequestCalendarEventDeletionState({this.lifecycle, this.calendarDeletionRequested = false});

  /// Null before any cancellation.
  final MeetingLifecycleState? lifecycle;
  final bool calendarDeletionRequested;

  RequestCalendarEventDeletionState copyWith({MeetingLifecycleState? lifecycle, bool? calendarDeletionRequested}) =>
      RequestCalendarEventDeletionState(
        lifecycle: lifecycle ?? this.lifecycle,
        calendarDeletionRequested: calendarDeletionRequested ?? this.calendarDeletionRequested,
      );

  @override
  bool operator ==(Object other) =>
      other is RequestCalendarEventDeletionState &&
      other.lifecycle == lifecycle &&
      other.calendarDeletionRequested == calendarDeletionRequested;

  @override
  int get hashCode => Object.hash(lifecycle, calendarDeletionRequested);

  @override
  String toString() =>
      'RequestCalendarEventDeletionState(lifecycle: $lifecycle, calendarDeletionRequested: $calendarDeletionRequested)';
}
