import '../../bounded_contexts/host_setup/api.dart';

/// The facts of one availability schedule that `remove_date_exception` decides on. `lifecycle` and `hostId` are null
/// before the schedule is created.
final class RemoveDateExceptionState {
  const RemoveDateExceptionState({this.lifecycle, this.hostId});

  final AvailabilityScheduleLifecycleState? lifecycle;
  final HostId? hostId;

  @override
  bool operator ==(Object other) =>
      other is RemoveDateExceptionState && other.lifecycle == lifecycle && other.hostId == hostId;

  @override
  int get hashCode => Object.hash(lifecycle, hostId);

  @override
  String toString() => 'RemoveDateExceptionState($lifecycle, $hostId)';
}
