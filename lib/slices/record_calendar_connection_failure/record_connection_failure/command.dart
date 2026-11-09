import '../../../bounded_contexts/host_setup/api.dart';

/// Records that the host's calendar connection failed (`record_connection_failure`). Sent by the processor
/// `connection_failure_translator` for a calendar access failure.
final class RecordConnectionFailureCommand {
  const RecordConnectionFailureCommand({required this.hostId, required this.connectionFailure});

  final HostId hostId;
  final ConnectionFailure connectionFailure;

  @override
  bool operator ==(Object other) =>
      other is RecordConnectionFailureCommand && other.hostId == hostId && other.connectionFailure == connectionFailure;

  @override
  int get hashCode => Object.hash(hostId, connectionFailure);

  @override
  String toString() => 'RecordConnectionFailureCommand(hostId: $hostId, connectionFailure: $connectionFailure)';
}
