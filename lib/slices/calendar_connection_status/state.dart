import '../../bounded_contexts/host_setup/api.dart';

/// Where the host's calendar connection stands. The latest of the three host setup events decides.
enum ConnectionStatus { connecting, connected, failed }

/// The read model `calendar_connection_status`: the answer to "Is my calendar connected, and if not, why not?".
/// Its key is the host id.
final class CalendarConnectionStatus {
  const CalendarConnectionStatus({
    required this.hostId,
    required this.connectionStatus,
    this.calendarAccount,
    this.connectionFailure,
  });

  factory CalendarConnectionStatus.fromJson(JsonMap json) => CalendarConnectionStatus(
    hostId: HostId(json['hostId']! as String),
    connectionStatus: ConnectionStatus.values.byName(json['connectionStatus']! as String),
    calendarAccount: switch (json['calendarAccount']) {
      final String account => CalendarAccount(account),
      _ => null,
    },
    connectionFailure: switch (json['connectionFailure']) {
      final String failure => ConnectionFailure(failure),
      _ => null,
    },
  );

  final HostId hostId;
  final ConnectionStatus connectionStatus;

  /// The connected calendar. Set only while the status is [ConnectionStatus.connected].
  final CalendarAccount? calendarAccount;

  /// The reason of the last failure. Set only while the status is [ConnectionStatus.failed].
  final ConnectionFailure? connectionFailure;

  JsonMap toJson() => {
    'hostId': hostId.value,
    'connectionStatus': connectionStatus.name,
    'calendarAccount': calendarAccount?.value,
    'connectionFailure': connectionFailure?.value,
  };

  @override
  bool operator ==(Object other) =>
      other is CalendarConnectionStatus &&
      other.hostId == hostId &&
      other.connectionStatus == connectionStatus &&
      other.calendarAccount == calendarAccount &&
      other.connectionFailure == connectionFailure;

  @override
  int get hashCode => Object.hash(hostId, connectionStatus, calendarAccount, connectionFailure);

  @override
  String toString() =>
      'CalendarConnectionStatus(hostId: $hostId, connectionStatus: $connectionStatus, calendarAccount: $calendarAccount, connectionFailure: $connectionFailure)';
}
