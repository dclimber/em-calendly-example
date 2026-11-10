import '../../../bounded_contexts/meetings/api.dart';

/// The meeting as the decider folds it: its lifecycle state, and whether its live check was already requested.
final class RequestBookingAvailabilityCheckState {
  const RequestBookingAvailabilityCheckState({this.lifecycle, this.checkRequested = false});

  /// Null before the meeting is reserved.
  final MeetingLifecycleState? lifecycle;
  final bool checkRequested;

  @override
  bool operator ==(Object other) =>
      other is RequestBookingAvailabilityCheckState &&
      other.lifecycle == lifecycle &&
      other.checkRequested == checkRequested;

  @override
  int get hashCode => Object.hash(lifecycle, checkRequested);

  @override
  String toString() => 'RequestBookingAvailabilityCheckState(lifecycle: $lifecycle, checkRequested: $checkRequested)';
}
