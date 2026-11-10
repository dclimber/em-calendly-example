import '../../../bounded_contexts/meetings/api.dart';

/// Records that the cancellation of a meeting was announced to its participants (`send_cancellation_notice`). Sent by
/// the processor `cancellation_notifier` for an item of `cancellation_notices_to_send`.
final class SendCancellationNoticeCommand {
  const SendCancellationNoticeCommand({required this.meetingId, required this.participants});

  final MeetingId meetingId;
  final Participants participants;

  @override
  bool operator ==(Object other) =>
      other is SendCancellationNoticeCommand && other.meetingId == meetingId && other.participants == participants;

  @override
  int get hashCode => Object.hash(meetingId, participants);

  @override
  String toString() => 'SendCancellationNoticeCommand(meetingId: $meetingId, participants: $participants)';
}
