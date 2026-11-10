import '../../../bounded_contexts/meetings/api.dart';

/// The meeting as the decider folds it: only its lifecycle state. Null before the meeting is reserved.
final class FailBookingState {
  const FailBookingState({this.lifecycle});

  final MeetingLifecycleState? lifecycle;

  @override
  bool operator ==(Object other) => other is FailBookingState && other.lifecycle == lifecycle;

  @override
  int get hashCode => lifecycle.hashCode;

  @override
  String toString() => 'FailBookingState(lifecycle: $lifecycle)';
}
