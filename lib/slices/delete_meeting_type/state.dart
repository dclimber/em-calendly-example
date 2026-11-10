import '../../bounded_contexts/host_setup/api.dart';

/// The facts of one meeting type that `delete_meeting_type` decides on. `lifecycle` and `hostId` are null before the
/// meeting type is created.
final class DeleteMeetingTypeState {
  const DeleteMeetingTypeState({this.lifecycle, this.hostId});

  final MeetingTypeLifecycleState? lifecycle;
  final HostId? hostId;

  @override
  bool operator ==(Object other) =>
      other is DeleteMeetingTypeState && other.lifecycle == lifecycle && other.hostId == hostId;

  @override
  int get hashCode => Object.hash(lifecycle, hostId);

  @override
  String toString() => 'DeleteMeetingTypeState($lifecycle, $hostId)';
}
