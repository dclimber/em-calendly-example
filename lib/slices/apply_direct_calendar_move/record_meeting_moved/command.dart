import '../../../bounded_contexts/meetings/api.dart';

/// Records that the calendar system moved the meeting's event directly (`record_meeting_moved`). Sent by the processor
/// `direct_move_translator` for an item of `direct_calendar_moves`.
final class RecordMeetingMovedCommand {
  const RecordMeetingMovedCommand({required this.meetingId, required this.newSlotStart, required this.newSlotEnd});

  final MeetingId meetingId;
  final NewSlotStart newSlotStart;
  final NewSlotEnd newSlotEnd;

  @override
  bool operator ==(Object other) =>
      other is RecordMeetingMovedCommand &&
      other.meetingId == meetingId &&
      other.newSlotStart == newSlotStart &&
      other.newSlotEnd == newSlotEnd;

  @override
  int get hashCode => Object.hash(meetingId, newSlotStart, newSlotEnd);

  @override
  String toString() =>
      'RecordMeetingMovedCommand(meetingId: $meetingId, newSlotStart: $newSlotStart, newSlotEnd: $newSlotEnd)';
}
