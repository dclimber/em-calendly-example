import '../../../bounded_contexts/meetings/api.dart';

/// A meeting that the calendar system deleted directly: the item of `direct_calendar_deletions`.
final class DirectCalendarDeletionState {
  const DirectCalendarDeletionState({required this.meetingId});

  final MeetingId meetingId;

  @override
  bool operator ==(Object other) => other is DirectCalendarDeletionState && other.meetingId == meetingId;

  @override
  int get hashCode => meetingId.hashCode;

  @override
  String toString() => 'DirectCalendarDeletionState(meetingId: $meetingId)';
}
