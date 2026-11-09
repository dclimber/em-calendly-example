import '../../bounded_contexts/host_setup/api.dart';

/// The facts of one availability schedule that `set_booking_limits` decides on. `lifecycle` and `hostId` are null
/// before the schedule is created.
final class SetBookingLimitsState {
  const SetBookingLimitsState({this.lifecycle, this.hostId});

  final AvailabilityScheduleLifecycleState? lifecycle;
  final HostId? hostId;

  @override
  bool operator ==(Object other) =>
      other is SetBookingLimitsState && other.lifecycle == lifecycle && other.hostId == hostId;

  @override
  int get hashCode => Object.hash(lifecycle, hostId);

  @override
  String toString() => 'SetBookingLimitsState($lifecycle, $hostId)';
}
