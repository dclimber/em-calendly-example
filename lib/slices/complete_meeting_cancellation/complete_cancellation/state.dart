import '../../../bounded_contexts/meetings/api.dart';

/// The meeting as the decider folds it: only its lifecycle state matters to the cancellation.
final class CompleteCancellationState {
  const CompleteCancellationState({this.lifecycle});

  /// Null before the meeting is reserved.
  final MeetingLifecycleState? lifecycle;

  @override
  bool operator ==(Object other) => other is CompleteCancellationState && other.lifecycle == lifecycle;

  @override
  int get hashCode => lifecycle.hashCode;

  @override
  String toString() => 'CompleteCancellationState(lifecycle: $lifecycle)';
}
