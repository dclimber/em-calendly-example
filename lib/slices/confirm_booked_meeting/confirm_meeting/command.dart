import '../../../bounded_contexts/meetings/api.dart';

/// Confirms a meeting with the calendar event that the calendar system created (`confirm_meeting`). Sent by the
/// processor `calendar_created_translator` for a calendar event that is not yet recorded.
final class ConfirmMeetingCommand {
  const ConfirmMeetingCommand({required this.meetingId, required this.calendarEventId});

  final MeetingId meetingId;
  final CalendarEventId calendarEventId;

  @override
  bool operator ==(Object other) =>
      other is ConfirmMeetingCommand && other.meetingId == meetingId && other.calendarEventId == calendarEventId;

  @override
  int get hashCode => Object.hash(meetingId, calendarEventId);

  @override
  String toString() => 'ConfirmMeetingCommand(meetingId: $meetingId, calendarEventId: $calendarEventId)';
}
