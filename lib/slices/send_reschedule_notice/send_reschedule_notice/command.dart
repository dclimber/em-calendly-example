import '../../../bounded_contexts/meetings/api.dart';

/// Sends the reschedule notice of a meeting's new time (`send_reschedule_notice`). Sent by the processor
/// `reschedule_notifier` for an item of `reschedule_notices_to_send`.
final class SendRescheduleNoticeCommand {
  const SendRescheduleNoticeCommand({
    required this.meetingId,
    required this.newSlotStart,
    required this.participants,
  });

  final MeetingId meetingId;
  final NewSlotStart newSlotStart;
  final Participants participants;

  @override
  bool operator ==(Object other) =>
      other is SendRescheduleNoticeCommand &&
      other.meetingId == meetingId &&
      other.newSlotStart == newSlotStart &&
      other.participants == participants;

  @override
  int get hashCode => Object.hash(meetingId, newSlotStart, participants);

  @override
  String toString() =>
      'SendRescheduleNoticeCommand(meetingId: $meetingId, newSlotStart: $newSlotStart, participants: $participants)';
}
