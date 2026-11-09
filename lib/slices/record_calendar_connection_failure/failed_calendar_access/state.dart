import '../../../bounded_contexts/host_setup/api.dart';

/// One calendar access failure that the calendar system reported. `hostId` is the host id that the scheduler user ref
/// names, and `connectionFailure` is the failure code of the calendar system.
final class FailedCalendarAccessState {
  const FailedCalendarAccessState({required this.hostId, required this.connectionFailure});

  final HostId hostId;
  final ConnectionFailure connectionFailure;

  @override
  bool operator ==(Object other) =>
      other is FailedCalendarAccessState && other.hostId == hostId && other.connectionFailure == connectionFailure;

  @override
  int get hashCode => Object.hash(hostId, connectionFailure);

  @override
  String toString() => 'FailedCalendarAccessState(hostId: $hostId, connectionFailure: $connectionFailure)';
}
