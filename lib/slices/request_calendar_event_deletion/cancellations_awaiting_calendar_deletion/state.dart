import '../../../bounded_contexts/meetings/api.dart';

/// A requested cancellation of `cancellations_awaiting_calendar_deletion`: its calendar event must still be removed.
/// The item is listed from `meeting_cancellation_requested` until `calendar_event_deletion_requested` or
/// `meeting_canceled` closes it.
final class CancellationAwaitingCalendarDeletionState {
  const CancellationAwaitingCalendarDeletionState({required this.meetingId, required this.calendarEventId});

  final MeetingId meetingId;
  final CalendarEventId calendarEventId;

  @override
  bool operator ==(Object other) =>
      other is CancellationAwaitingCalendarDeletionState &&
      other.meetingId == meetingId &&
      other.calendarEventId == calendarEventId;

  @override
  int get hashCode => Object.hash(meetingId, calendarEventId);

  @override
  String toString() =>
      'CancellationAwaitingCalendarDeletionState(meetingId: $meetingId, calendarEventId: $calendarEventId)';
}
