import '../../../bounded_contexts/meetings/api.dart';

/// Asks the calendar system to remove the event of a requested cancellation (`request_calendar_event_deletion`). Sent
/// by the processor `calendar_deletion_requester` for an item of `cancellations_awaiting_calendar_deletion`.
final class RequestCalendarEventDeletionCommand {
  const RequestCalendarEventDeletionCommand({required this.meetingId});

  final MeetingId meetingId;

  @override
  bool operator ==(Object other) => other is RequestCalendarEventDeletionCommand && other.meetingId == meetingId;

  @override
  int get hashCode => meetingId.hashCode;

  @override
  String toString() => 'RequestCalendarEventDeletionCommand(meetingId: $meetingId)';
}
