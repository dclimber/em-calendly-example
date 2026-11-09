import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import '../../../bounded_contexts/host_setup/api.dart';
import '../../../ui/kit.dart';
import '../../../ui/paths.dart';
import '../service.dart';
import '../state.dart';

/// The screen `calendar_connection` of the host's own connection status.
final class CalendarConnectionPage extends AsyncStatelessComponent {
  const CalendarConnectionPage({required this.service, required this.hostId, super.key});

  final CalendarConnectionStatusService service;
  final HostId hostId;

  @override
  Future<Component> build(BuildContext context) async {
    final status = await service.statusFor(hostId);
    final connectionStatus = status?.connectionStatus;

    return Panel(
      title: 'Calendar connection',
      children: [
        Facts([
          ('Status', _badge(connectionStatus)),
          if (status?.calendarAccount case final account?) ('Calendar', Component.text(account.value)),
          if (status?.connectionFailure case final failure?) ('Reason', Component.text(failure.value)),
        ]),
        p([Component.text(_message(connectionStatus))]),
        if (connectionStatus != ConnectionStatus.connected)
          PostButton(action: connectCalendarAction, label: 'Connect calendar'),
      ],
    );
  }
}

Component _badge(ConnectionStatus? status) => switch (status) {
  null => const Badge('Not connected'),
  ConnectionStatus.connecting => const Badge('Connecting', tone: BadgeTone.warning),
  ConnectionStatus.connected => const Badge('Connected', tone: BadgeTone.good),
  ConnectionStatus.failed => const Badge('Failed', tone: BadgeTone.bad),
};

String _message(ConnectionStatus? status) => switch (status) {
  null => 'Your calendar is not connected yet.',
  ConnectionStatus.connecting => 'Your calendar is being connected.',
  ConnectionStatus.connected => 'Your calendar is connected.',
  ConnectionStatus.failed => 'The last connection attempt failed.',
};
