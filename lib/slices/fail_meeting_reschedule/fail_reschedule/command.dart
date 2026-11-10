import '../../../bounded_contexts/meetings/api.dart';

/// Records that a reschedule of a meeting failed (`fail_reschedule`). Sent by the processor
/// `calendar_update_failure_translator` for a listed negative answer of the calendar system.
final class FailRescheduleCommand {
  const FailRescheduleCommand({required this.meetingId, required this.failureReason});

  final MeetingId meetingId;
  final FailureReason failureReason;

  @override
  bool operator ==(Object other) =>
      other is FailRescheduleCommand && other.meetingId == meetingId && other.failureReason == failureReason;

  @override
  int get hashCode => Object.hash(meetingId, failureReason);

  @override
  String toString() => 'FailRescheduleCommand(meetingId: $meetingId, failureReason: $failureReason)';
}
