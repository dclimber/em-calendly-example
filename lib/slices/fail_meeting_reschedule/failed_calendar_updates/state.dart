import '../../../bounded_contexts/meetings/api.dart';

/// One negative answer of the calendar system about a reschedule: the meeting it names, and the reason the reschedule
/// fails.
final class FailedCalendarUpdateState {
  const FailedCalendarUpdateState({required this.meetingId, required this.failureReason});

  final MeetingId meetingId;
  final FailureReason failureReason;

  @override
  bool operator ==(Object other) =>
      other is FailedCalendarUpdateState && other.meetingId == meetingId && other.failureReason == failureReason;

  @override
  int get hashCode => Object.hash(meetingId, failureReason);

  @override
  String toString() => 'FailedCalendarUpdateState(meetingId: $meetingId, failureReason: $failureReason)';
}
