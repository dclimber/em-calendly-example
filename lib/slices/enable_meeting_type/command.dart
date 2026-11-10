import '../../bounded_contexts/host_setup/api.dart';

/// Enables a meeting type (`enable_meeting_type`). `host_id` is the signed-in host; the decider refuses an enable by
/// anyone else (the model's command has no host field; see the gap report).
final class EnableMeetingTypeCommand {
  const EnableMeetingTypeCommand({required this.meetingTypeId, required this.hostId});

  final MeetingTypeId meetingTypeId;
  final HostId hostId;

  @override
  bool operator ==(Object other) =>
      other is EnableMeetingTypeCommand && other.meetingTypeId == meetingTypeId && other.hostId == hostId;

  @override
  int get hashCode => Object.hash(meetingTypeId, hostId);

  @override
  String toString() => 'EnableMeetingTypeCommand($meetingTypeId, $hostId)';
}
