import '../../../bounded_contexts/meetings/api.dart';

/// The meeting as the decider folds it: its lifecycle state, and whether its booked slot was already verified.
final class RecordBookingSlotVerifiedState {
  const RecordBookingSlotVerifiedState({this.lifecycle, this.slotVerified = false});

  /// Null before the meeting is reserved.
  final MeetingLifecycleState? lifecycle;
  final bool slotVerified;

  @override
  bool operator ==(Object other) =>
      other is RecordBookingSlotVerifiedState && other.lifecycle == lifecycle && other.slotVerified == slotVerified;

  @override
  int get hashCode => Object.hash(lifecycle, slotVerified);

  @override
  String toString() => 'RecordBookingSlotVerifiedState(lifecycle: $lifecycle, slotVerified: $slotVerified)';
}
