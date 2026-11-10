import '../../../bounded_contexts/meetings/api.dart';

/// The meeting as the decider folds it: only its lifecycle state matters to the failure. Null before the meeting is
/// reserved.
final class FailRescheduleState {
  const FailRescheduleState({this.lifecycle});

  final MeetingLifecycleState? lifecycle;

  @override
  bool operator ==(Object other) => other is FailRescheduleState && other.lifecycle == lifecycle;

  @override
  int get hashCode => lifecycle.hashCode;

  @override
  String toString() => 'FailRescheduleState(lifecycle: $lifecycle)';
}
