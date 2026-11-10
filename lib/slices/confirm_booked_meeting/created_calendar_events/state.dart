import '../../../bounded_contexts/meetings/api.dart';

/// A meeting whose calendar event the calendar system has created: the item of `created_calendar_events`.
final class CreatedCalendarEventState {
  const CreatedCalendarEventState({required this.meetingId, required this.calendarEventId});

  final MeetingId meetingId;
  final CalendarEventId calendarEventId;

  @override
  bool operator ==(Object other) =>
      other is CreatedCalendarEventState && other.meetingId == meetingId && other.calendarEventId == calendarEventId;

  @override
  int get hashCode => Object.hash(meetingId, calendarEventId);

  @override
  String toString() => 'CreatedCalendarEventState(meetingId: $meetingId, calendarEventId: $calendarEventId)';
}
