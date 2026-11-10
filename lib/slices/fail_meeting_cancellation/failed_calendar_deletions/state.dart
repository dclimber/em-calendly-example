import '../../../bounded_contexts/meetings/api.dart';

/// One failed calendar deletion: the meeting that the calendar system could not remove, and the failure code that it gave,
/// kept as the reason that the cancellation fails.
final class FailedCalendarDeletionState {
  const FailedCalendarDeletionState({required this.meetingId, required this.failureReason});

  final MeetingId meetingId;
  final FailureReason failureReason;

  @override
  bool operator ==(Object other) =>
      other is FailedCalendarDeletionState && other.meetingId == meetingId && other.failureReason == failureReason;

  @override
  int get hashCode => Object.hash(meetingId, failureReason);

  @override
  String toString() => 'FailedCalendarDeletionState(meetingId: $meetingId, failureReason: $failureReason)';
}
