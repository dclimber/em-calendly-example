import '../../../bounded_contexts/meetings/api.dart';

/// One negative answer of the calendar system about a booking: the meeting it names, and the reason the booking fails.
final class FailedCalendarEventState {
  const FailedCalendarEventState({required this.meetingId, required this.failureReason});

  final MeetingId meetingId;
  final FailureReason failureReason;

  @override
  bool operator ==(Object other) =>
      other is FailedCalendarEventState && other.meetingId == meetingId && other.failureReason == failureReason;

  @override
  int get hashCode => Object.hash(meetingId, failureReason);

  @override
  String toString() => 'FailedCalendarEventState(meetingId: $meetingId, failureReason: $failureReason)';
}
