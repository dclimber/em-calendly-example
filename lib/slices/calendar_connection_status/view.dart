import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/host_setup/api.dart';
import 'state.dart';

/// The pure view of `calendar_connection_status`. Each of the three events replaces the document: the latest
/// event decides the status, the connected calendar, and the failure. Other host setup events change nothing.
final calendarConnectionStatusView = View<CalendarConnectionStatus?, HostSetupEvent>(
  initialState: null,
  evolve: (state, event) => switch (event) {
    CalendarConnectionStartedEvent(:final hostId) => CalendarConnectionStatus(
      hostId: hostId,
      connectionStatus: ConnectionStatus.connecting,
    ),
    CalendarConnectedEvent(:final hostId, :final calendarAccount) => CalendarConnectionStatus(
      hostId: hostId,
      connectionStatus: ConnectionStatus.connected,
      calendarAccount: calendarAccount,
    ),
    CalendarConnectionFailedEvent(:final hostId, :final connectionFailure) => CalendarConnectionStatus(
      hostId: hostId,
      connectionStatus: ConnectionStatus.failed,
      connectionFailure: connectionFailure,
    ),
    _ => state,
  },
);
