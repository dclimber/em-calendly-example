import '../../bounded_contexts/meetings/api.dart';

/// The `request_meeting_cancellation` command. [requestedBy] is the signed-in viewer. The host, calendar event, and
/// participants of the cancellation come from the meeting's own stream, so the decision reads them there.
final class RequestMeetingCancellationCommand {
  const RequestMeetingCancellationCommand({required this.meetingId, required this.requestedBy});

  final MeetingId meetingId;
  final RequestedBy requestedBy;

  @override
  bool operator ==(Object other) =>
      other is RequestMeetingCancellationCommand && other.meetingId == meetingId && other.requestedBy == requestedBy;

  @override
  int get hashCode => Object.hash(meetingId, requestedBy);

  @override
  String toString() => 'RequestMeetingCancellationCommand(meetingId: $meetingId, requestedBy: $requestedBy)';
}
