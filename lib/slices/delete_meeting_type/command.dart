import '../../bounded_contexts/host_setup/api.dart';

/// Deletes a meeting type (`delete_meeting_type`). `host_id` is the signed-in host; the decider refuses a delete by
/// anyone else (the model's command has no host field; see the gap report).
final class DeleteMeetingTypeCommand {
  const DeleteMeetingTypeCommand({required this.meetingTypeId, required this.hostId});

  final MeetingTypeId meetingTypeId;
  final HostId hostId;

  @override
  bool operator ==(Object other) =>
      other is DeleteMeetingTypeCommand && other.meetingTypeId == meetingTypeId && other.hostId == hostId;

  @override
  int get hashCode => Object.hash(meetingTypeId, hostId);

  @override
  String toString() => 'DeleteMeetingTypeCommand($meetingTypeId, $hostId)';
}
