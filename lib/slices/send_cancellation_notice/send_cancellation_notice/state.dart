import '../../../bounded_contexts/meetings/api.dart';

/// The meeting as the decider folds it: its lifecycle state, and whether the cancellation notice was already sent.
final class SendCancellationNoticeState {
  const SendCancellationNoticeState({this.lifecycle, this.noticeSent = false});

  /// Null before the meeting is reserved.
  final MeetingLifecycleState? lifecycle;
  final bool noticeSent;

  @override
  bool operator ==(Object other) =>
      other is SendCancellationNoticeState && other.lifecycle == lifecycle && other.noticeSent == noticeSent;

  @override
  int get hashCode => Object.hash(lifecycle, noticeSent);

  @override
  String toString() => 'SendCancellationNoticeState(lifecycle: $lifecycle, noticeSent: $noticeSent)';
}
