import '../../../bounded_contexts/meetings/api.dart';

/// A meeting whose calendar event the calendar system has moved: the item of `updated_calendar_events`.
final class UpdatedCalendarEventState {
  const UpdatedCalendarEventState({required this.meetingId});

  final MeetingId meetingId;

  @override
  bool operator ==(Object other) => other is UpdatedCalendarEventState && other.meetingId == meetingId;

  @override
  int get hashCode => meetingId.hashCode;

  @override
  String toString() => 'UpdatedCalendarEventState(meetingId: $meetingId)';
}
