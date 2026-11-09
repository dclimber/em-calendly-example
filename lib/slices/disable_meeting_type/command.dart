import '../../bounded_contexts/host_setup/api.dart';

/// Disables a meeting type (`disable_meeting_type`). `host_id` is the signed-in host; the decider refuses a disable by
/// anyone else (the model's command has no host field; see the gap report).
final class DisableMeetingTypeCommand {
  const DisableMeetingTypeCommand({required this.meetingTypeId, required this.hostId});

  final MeetingTypeId meetingTypeId;
  final HostId hostId;

  @override
  bool operator ==(Object other) =>
      other is DisableMeetingTypeCommand && other.meetingTypeId == meetingTypeId && other.hostId == hostId;

  @override
  int get hashCode => Object.hash(meetingTypeId, hostId);

  @override
  String toString() => 'DisableMeetingTypeCommand($meetingTypeId, $hostId)';
}
