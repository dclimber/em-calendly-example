import '../../../bounded_contexts/meetings/api.dart';

/// The meeting as the decider folds it: its lifecycle state, and the new slot start of the last reschedule notice
/// that was sent (null before the first notice).
final class SendRescheduleNoticeState {
  const SendRescheduleNoticeState({this.lifecycle, this.lastNoticedNewSlotStart});

  /// Null before the meeting is reserved.
  final MeetingLifecycleState? lifecycle;
  final NewSlotStart? lastNoticedNewSlotStart;

  @override
  bool operator ==(Object other) =>
      other is SendRescheduleNoticeState &&
      other.lifecycle == lifecycle &&
      other.lastNoticedNewSlotStart == lastNoticedNewSlotStart;

  @override
  int get hashCode => Object.hash(lifecycle, lastNoticedNewSlotStart);

  @override
  String toString() =>
      'SendRescheduleNoticeState(lifecycle: $lifecycle, lastNoticedNewSlotStart: $lastNoticedNewSlotStart)';
}
