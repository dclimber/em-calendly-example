import '../../../bounded_contexts/meetings/api.dart';

/// The lifecycle state of the `meeting` that the decider folds. Null before the reservation.
final class CompleteMeetingState {
  const CompleteMeetingState({this.lifecycle});

  final MeetingLifecycleState? lifecycle;

  @override
  bool operator ==(Object other) => other is CompleteMeetingState && other.lifecycle == lifecycle;

  @override
  int get hashCode => lifecycle.hashCode;

  @override
  String toString() => 'CompleteMeetingState(lifecycle: $lifecycle)';
}
