import '../../bounded_contexts/host_setup/api.dart';

/// The facts of one availability schedule that `change_date_exception` decides on. `lifecycle` and `hostId` are null
/// before the schedule is created.
final class ChangeDateExceptionState {
  const ChangeDateExceptionState({this.lifecycle, this.hostId});

  final AvailabilityScheduleLifecycleState? lifecycle;
  final HostId? hostId;

  @override
  bool operator ==(Object other) =>
      other is ChangeDateExceptionState && other.lifecycle == lifecycle && other.hostId == hostId;

  @override
  int get hashCode => Object.hash(lifecycle, hostId);

  @override
  String toString() => 'ChangeDateExceptionState($lifecycle, $hostId)';
}
