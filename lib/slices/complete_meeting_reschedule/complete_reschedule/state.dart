import '../../../bounded_contexts/meetings/api.dart';

/// The meeting as the decider folds it: only its lifecycle state matters to the completion.
final class CompleteRescheduleState {
  const CompleteRescheduleState({this.lifecycle});

  /// Null before the meeting is reserved.
  final MeetingLifecycleState? lifecycle;

  @override
  bool operator ==(Object other) => other is CompleteRescheduleState && other.lifecycle == lifecycle;

  @override
  int get hashCode => lifecycle.hashCode;

  @override
  String toString() => 'CompleteRescheduleState(lifecycle: $lifecycle)';
}
