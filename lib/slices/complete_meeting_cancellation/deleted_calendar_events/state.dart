import '../../../bounded_contexts/meetings/api.dart';

/// A meeting whose calendar event the calendar system has deleted: the item of `deleted_calendar_events`.
final class DeletedCalendarEventState {
  const DeletedCalendarEventState({required this.meetingId});

  final MeetingId meetingId;

  @override
  bool operator ==(Object other) => other is DeletedCalendarEventState && other.meetingId == meetingId;

  @override
  int get hashCode => meetingId.hashCode;

  @override
  String toString() => 'DeletedCalendarEventState(meetingId: $meetingId)';
}
