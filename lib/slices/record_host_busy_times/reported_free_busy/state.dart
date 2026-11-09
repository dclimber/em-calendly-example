import '../../../bounded_contexts/host_setup/api.dart';

/// The free/busy data that one `free_busy_reported` event carries, for one host. `hostId` is the host id that the
/// scheduler user ref names.
final class ReportedFreeBusyState {
  const ReportedFreeBusyState({required this.hostId, required this.busyIntervals});

  final HostId hostId;
  final BusyIntervals busyIntervals;

  @override
  bool operator ==(Object other) =>
      other is ReportedFreeBusyState && other.hostId == hostId && other.busyIntervals == busyIntervals;

  @override
  int get hashCode => Object.hash(hostId, busyIntervals);

  @override
  String toString() => 'ReportedFreeBusyState(hostId: $hostId, busyIntervals: $busyIntervals)';
}
