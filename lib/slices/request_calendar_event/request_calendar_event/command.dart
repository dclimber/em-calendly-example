import '../../../bounded_contexts/meetings/api.dart';

/// Asks the calendar system to create the event of a verified reservation (`request_calendar_event`). Sent by the
/// processor `calendar_event_requester` for an item of `reservations_awaiting_calendar_event`.
final class RequestCalendarEventCommand {
  const RequestCalendarEventCommand({required this.meetingId});

  final MeetingId meetingId;

  @override
  bool operator ==(Object other) => other is RequestCalendarEventCommand && other.meetingId == meetingId;

  @override
  int get hashCode => meetingId.hashCode;

  @override
  String toString() => 'RequestCalendarEventCommand(meetingId: $meetingId)';
}
