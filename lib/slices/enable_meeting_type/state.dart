import '../../bounded_contexts/host_setup/api.dart';

/// The facts of one meeting type that `enable_meeting_type` decides on. `lifecycle` and `hostId` are null before the
/// meeting type is created.
final class EnableMeetingTypeState {
  const EnableMeetingTypeState({this.lifecycle, this.hostId});

  final MeetingTypeLifecycleState? lifecycle;
  final HostId? hostId;

  @override
  bool operator ==(Object other) =>
      other is EnableMeetingTypeState && other.lifecycle == lifecycle && other.hostId == hostId;

  @override
  int get hashCode => Object.hash(lifecycle, hostId);

  @override
  String toString() => 'EnableMeetingTypeState($lifecycle, $hostId)';
}
