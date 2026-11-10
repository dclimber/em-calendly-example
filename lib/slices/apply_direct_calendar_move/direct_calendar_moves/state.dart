import '../../../bounded_contexts/meetings/api.dart';

/// A meeting that the calendar system moved directly: the item of `direct_calendar_moves`.
final class DirectCalendarMoveState {
  const DirectCalendarMoveState({required this.meetingId, required this.newSlotStart, required this.newSlotEnd});

  final MeetingId meetingId;
  final NewSlotStart newSlotStart;
  final NewSlotEnd newSlotEnd;

  @override
  bool operator ==(Object other) =>
      other is DirectCalendarMoveState &&
      other.meetingId == meetingId &&
      other.newSlotStart == newSlotStart &&
      other.newSlotEnd == newSlotEnd;

  @override
  int get hashCode => Object.hash(meetingId, newSlotStart, newSlotEnd);

  @override
  String toString() =>
      'DirectCalendarMoveState(meetingId: $meetingId, newSlotStart: $newSlotStart, newSlotEnd: $newSlotEnd)';
}
