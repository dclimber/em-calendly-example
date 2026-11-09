import '../../../bounded_contexts/host_setup/api.dart';

/// Records that the host's calendar is connected (`record_calendar_connected`). Sent by the processor
/// `connection_translator` for a granted calendar access.
final class RecordCalendarConnectedCommand {
  const RecordCalendarConnectedCommand({required this.hostId, required this.calendarAccount});

  final HostId hostId;
  final CalendarAccount calendarAccount;

  @override
  bool operator ==(Object other) =>
      other is RecordCalendarConnectedCommand && other.hostId == hostId && other.calendarAccount == calendarAccount;

  @override
  int get hashCode => Object.hash(hostId, calendarAccount);

  @override
  String toString() => 'RecordCalendarConnectedCommand(hostId: $hostId, calendarAccount: $calendarAccount)';
}
