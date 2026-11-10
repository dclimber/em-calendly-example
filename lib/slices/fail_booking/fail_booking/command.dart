import '../../../bounded_contexts/meetings/api.dart';

/// Records that the booking of a meeting failed (`fail_booking`). Sent by the processor `calendar_failure_translator`
/// for a listed negative answer of the calendar system.
final class FailBookingCommand {
  const FailBookingCommand({required this.meetingId, required this.failureReason});

  final MeetingId meetingId;
  final FailureReason failureReason;

  @override
  bool operator ==(Object other) =>
      other is FailBookingCommand && other.meetingId == meetingId && other.failureReason == failureReason;

  @override
  int get hashCode => Object.hash(meetingId, failureReason);

  @override
  String toString() => 'FailBookingCommand(meetingId: $meetingId, failureReason: $failureReason)';
}
