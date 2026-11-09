import '../../../bounded_contexts/host_setup/api.dart';

/// Records the host's busy intervals on the `calendar_connection` aggregate (`record_busy_times`). Sent by the
/// processor `free_busy_translator` for a reported free/busy answer.
final class RecordBusyTimesCommand {
  const RecordBusyTimesCommand({required this.hostId, required this.busyIntervals});

  final HostId hostId;
  final BusyIntervals busyIntervals;

  @override
  bool operator ==(Object other) =>
      other is RecordBusyTimesCommand && other.hostId == hostId && other.busyIntervals == busyIntervals;

  @override
  int get hashCode => Object.hash(hostId, busyIntervals);

  @override
  String toString() => 'RecordBusyTimesCommand(hostId: $hostId, busyIntervals: $busyIntervals)';
}
