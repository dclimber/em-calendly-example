import '../../../bounded_contexts/meetings/api.dart';

/// Records that the calendar system deleted the meeting's event directly (`record_meeting_deleted`). Sent by the
/// processor `direct_deletion_translator` for an item of `direct_calendar_deletions`.
final class RecordMeetingDeletedCommand {
  const RecordMeetingDeletedCommand({required this.meetingId});

  final MeetingId meetingId;

  @override
  bool operator ==(Object other) => other is RecordMeetingDeletedCommand && other.meetingId == meetingId;

  @override
  int get hashCode => meetingId.hashCode;

  @override
  String toString() => 'RecordMeetingDeletedCommand(meetingId: $meetingId)';
}
