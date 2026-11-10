import '../../../bounded_contexts/meetings/api.dart';

/// The meeting as the decider folds it: only its lifecycle state matters to the failure. Null before the meeting is
/// reserved.
final class FailCancellationState {
  const FailCancellationState({this.lifecycle});

  final MeetingLifecycleState? lifecycle;

  @override
  bool operator ==(Object other) => other is FailCancellationState && other.lifecycle == lifecycle;

  @override
  int get hashCode => lifecycle.hashCode;

  @override
  String toString() => 'FailCancellationState(lifecycle: $lifecycle)';
}
