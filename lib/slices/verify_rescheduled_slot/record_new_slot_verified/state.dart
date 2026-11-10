import '../../../bounded_contexts/meetings/api.dart';

/// The meeting as the decider folds it: its lifecycle state, and whether the new slot of its current reschedule
/// request was already verified.
final class RecordNewSlotVerifiedState {
  const RecordNewSlotVerifiedState({this.lifecycle, this.newSlotVerified = false});

  /// Null before the meeting is reserved.
  final MeetingLifecycleState? lifecycle;

  /// Reset by each `meeting_reschedule_requested`; a repeat for the same reschedule request is refused.
  final bool newSlotVerified;

  @override
  bool operator ==(Object other) =>
      other is RecordNewSlotVerifiedState && other.lifecycle == lifecycle && other.newSlotVerified == newSlotVerified;

  @override
  int get hashCode => Object.hash(lifecycle, newSlotVerified);

  @override
  String toString() => 'RecordNewSlotVerifiedState(lifecycle: $lifecycle, newSlotVerified: $newSlotVerified)';
}
