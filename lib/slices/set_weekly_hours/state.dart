import '../../bounded_contexts/host_setup/api.dart';

/// The facts of one availability schedule that `set_weekly_hours` decides on. `lifecycle` and `hostId` are null
/// before the schedule is created.
final class SetWeeklyHoursState {
  const SetWeeklyHoursState({this.lifecycle, this.hostId});

  final AvailabilityScheduleLifecycleState? lifecycle;
  final HostId? hostId;

  @override
  bool operator ==(Object other) =>
      other is SetWeeklyHoursState && other.lifecycle == lifecycle && other.hostId == hostId;

  @override
  int get hashCode => Object.hash(lifecycle, hostId);

  @override
  String toString() => 'SetWeeklyHoursState($lifecycle, $hostId)';
}
