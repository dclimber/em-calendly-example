import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/record_calendar_connected/record_calendar_connected/command.dart';
import 'package:em_calendly_example/slices/record_calendar_connected/record_calendar_connected/decider.dart';
import 'package:em_calendly_example/slices/record_calendar_connected/record_calendar_connected/state.dart';
import 'package:test/test.dart';

final _hostId = HostId('alice-employee-id');
final _account = CalendarAccount('alice@example.com');
final _command = RecordCalendarConnectedCommand(hostId: _hostId, calendarAccount: _account);

void main() {
  // @requires the host's calendar connection is connecting
  // @ensures scenario grant_connects_the_calendar: the command emits calendar_connected for the host and account
  test('grant_connects_the_calendar', () async {
    final history = [CalendarConnectionStartedEvent(hostId: _hostId)];
    final state = history.fold(recordCalendarConnectedDecider.initialState, recordCalendarConnectedDecider.evolve);
    final events = await recordCalendarConnectedDecider.decide(_command, state).toList();
    expect(events, [CalendarConnectedEvent(hostId: _hostId, calendarAccount: _account)]);
  });

  // @requires any lifecycle state, including no history (a gap: the model states the transition only from connecting)
  // @ensures the decider emits exactly one calendar_connected in every state
  test('accepts the command in every lifecycle state', () async {
    final histories = <List<HostSetupEvent>>[
      const [],
      [CalendarConnectionStartedEvent(hostId: _hostId)],
      [CalendarConnectedEvent(hostId: _hostId, calendarAccount: _account)],
      [CalendarConnectionFailedEvent(hostId: _hostId, connectionFailure: ConnectionFailure('timeout'))],
    ];
    for (final history in histories) {
      final state = history.fold(recordCalendarConnectedDecider.initialState, recordCalendarConnectedDecider.evolve);
      final events = await recordCalendarConnectedDecider.decide(_command, state).toList();
      expect(events, hasLength(1), reason: 'history: $history');
      expect(events.single, isA<CalendarConnectedEvent>());
    }
  });

  // @requires the lifecycle folded from a history
  // @ensures evolve tracks the lifecycle: connecting, connected, connection_failed
  test('evolve tracks the lifecycle', () {
    final d = recordCalendarConnectedDecider;
    expect(
      d.evolve(d.initialState, CalendarConnectionStartedEvent(hostId: _hostId)),
      const RecordCalendarConnectedState(lifecycle: CalendarConnectionLifecycleState.connecting),
    );
    expect(
      d.evolve(d.initialState, CalendarConnectedEvent(hostId: _hostId, calendarAccount: _account)),
      const RecordCalendarConnectedState(lifecycle: CalendarConnectionLifecycleState.connected),
    );
    expect(
      d.evolve(
        d.initialState,
        CalendarConnectionFailedEvent(hostId: _hostId, connectionFailure: ConnectionFailure('timeout')),
      ),
      const RecordCalendarConnectedState(lifecycle: CalendarConnectionLifecycleState.connectionFailed),
    );
  });
}
