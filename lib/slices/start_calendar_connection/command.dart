import '../../bounded_contexts/host_setup/api.dart';

/// Starts the host's calendar connection (`start_calendar_connection`).
final class StartCalendarConnectionCommand {
  const StartCalendarConnectionCommand({required this.hostId});

  final HostId hostId;

  @override
  bool operator ==(Object other) => other is StartCalendarConnectionCommand && other.hostId == hostId;

  @override
  int get hashCode => hostId.hashCode;

  @override
  String toString() => 'StartCalendarConnectionCommand($hostId)';
}
