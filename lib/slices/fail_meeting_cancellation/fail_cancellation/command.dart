import '../../../bounded_contexts/meetings/api.dart';

/// Records that the calendar system could not remove the event of a canceling meeting (`fail_cancellation`). Sent by the
/// processor `calendar_deletion_failure_translator` for a listed `calendar_event_deletion_failed` answer.
final class FailCancellationCommand {
  const FailCancellationCommand({required this.meetingId, required this.failureReason});

  final MeetingId meetingId;
  final FailureReason failureReason;

  @override
  bool operator ==(Object other) =>
      other is FailCancellationCommand && other.meetingId == meetingId && other.failureReason == failureReason;

  @override
  int get hashCode => Object.hash(meetingId, failureReason);

  @override
  String toString() => 'FailCancellationCommand(meetingId: $meetingId, failureReason: $failureReason)';
}
