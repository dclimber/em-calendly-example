import '../../bounded_contexts/host_setup/api.dart';

/// The decider state of one meeting type. `lifecycle` is null before the first event. `scheduleOwner` is the host
/// who created the availability schedule that the command names, or null when no such schedule exists.
final class CreateMeetingTypeState {
  const CreateMeetingTypeState({this.lifecycle, this.scheduleOwner});

  final MeetingTypeLifecycleState? lifecycle;
  final HostId? scheduleOwner;

  @override
  bool operator ==(Object other) =>
      other is CreateMeetingTypeState && other.lifecycle == lifecycle && other.scheduleOwner == scheduleOwner;

  @override
  int get hashCode => Object.hash(lifecycle, scheduleOwner);

  @override
  String toString() => 'CreateMeetingTypeState($lifecycle, $scheduleOwner)';
}
