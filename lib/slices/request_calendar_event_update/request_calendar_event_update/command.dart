import '../../../bounded_contexts/meetings/api.dart';

/// Asks the calendar system to move the event of a verified reschedule (`request_calendar_event_update`). Sent by the
/// processor `calendar_update_requester` for an item of `reschedules_awaiting_calendar_update`.
final class RequestCalendarEventUpdateCommand {
  const RequestCalendarEventUpdateCommand({required this.meetingId, required this.newSlotStart});

  final MeetingId meetingId;
  final NewSlotStart newSlotStart;

  @override
  bool operator ==(Object other) =>
      other is RequestCalendarEventUpdateCommand && other.meetingId == meetingId && other.newSlotStart == newSlotStart;

  @override
  int get hashCode => Object.hash(meetingId, newSlotStart);

  @override
  String toString() => 'RequestCalendarEventUpdateCommand(meetingId: $meetingId, newSlotStart: $newSlotStart)';
}
