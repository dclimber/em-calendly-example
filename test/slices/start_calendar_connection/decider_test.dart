import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/start_calendar_connection/command.dart';
import 'package:em_calendly_example/slices/start_calendar_connection/decider.dart';
import 'package:em_calendly_example/slices/start_calendar_connection/errors.dart';
import 'package:em_calendly_example/slices/start_calendar_connection/state.dart';
import 'package:test/test.dart';

final _host = HostId('alice-employee-id');
final _command = StartCalendarConnectionCommand(hostId: _host);

final _started = CalendarConnectionStartedEvent(hostId: _host);
final _connected = CalendarConnectedEvent(hostId: _host, calendarAccount: CalendarAccount('alice@example.com'));
final _failed = CalendarConnectionFailedEvent(hostId: _host, connectionFailure: ConnectionFailure('timeout'));
final _busy = HostBusyTimesRecordedEvent(
  hostId: _host,
  busyIntervals: BusyIntervals(const []),
);

StartCalendarConnectionState _foldHistory(List<HostSetupEvent> history) =>
    history.fold(startCalendarConnectionDecider.initialState, startCalendarConnectionDecider.evolve);

/// The events of a decision, or the error it throws.
Future<Object> _outcome(StartCalendarConnectionCommand command, StartCalendarConnectionState state) async {
  try {
    return await startCalendarConnectionDecider.decide(command, state).toList();
  } on StartCalendarConnectionError catch (error) {
    return error;
  }
}

void main() {
  group('happy_path', () {
    // @requires no calendar_connection events for the host
    // @ensures scenario host_starts_connection: exactly calendar_connection_started for the host
    test('host_starts_connection', () async {
      final events = await startCalendarConnectionDecider.decide(_command, _foldHistory([])).toList();
      expect(events, [_started]);
    });
  });

  group('alternative_path', () {
    // @requires the last calendar_connection event is calendar_connection_failed
    // @ensures scenario host_retries_after_failure: exactly calendar_connection_started for the host
    test('host_retries_after_failure', () async {
      final events = await startCalendarConnectionDecider.decide(_command, _foldHistory([_failed])).toList();
      expect(events, [_started]);
    });
  });

  group('state_violation', () {
    // @requires the host's calendar is connected
    // @ensures scenario connected_calendar_is_not_connected_twice: error "This calendar is already connected."
    test('connected_calendar_is_not_connected_twice', () async {
      await expectLater(
        startCalendarConnectionDecider.decide(_command, _foldHistory([_connected])).toList(),
        throwsA(
          isA<StartWhenAlreadyConnectedError>().having(
            (e) => e.message,
            'message',
            'This calendar is already connected.',
          ),
        ),
      );
    });
  });

  group('model_gap', () {
    // @requires the last calendar_connection event is calendar_connection_started (state connecting)
    // @ensures the model states no rule for connecting, so the decider accepts the command (see the slice report)
    test('connecting_accepts_the_command_no_model_rule', () async {
      final events = await startCalendarConnectionDecider.decide(_command, _foldHistory([_started])).toList();
      expect(events, [_started]);
    });
  });

  group('lifecycle_evolve', () {
    // @requires any history of the calendar_connection events
    // @ensures evolve maps each event of the lifecycle to its after state
    test('evolve sets the lifecycle state of each event', () {
      final decider = startCalendarConnectionDecider;
      expect(
        decider.evolve(decider.initialState, _started),
        const StartCalendarConnectionState(lifecycle: CalendarConnectionLifecycleState.connecting),
      );
      expect(
        decider.evolve(decider.initialState, _connected),
        const StartCalendarConnectionState(lifecycle: CalendarConnectionLifecycleState.connected),
      );
      expect(
        decider.evolve(decider.initialState, _busy),
        const StartCalendarConnectionState(lifecycle: CalendarConnectionLifecycleState.connected),
      );
      expect(
        decider.evolve(decider.initialState, _failed),
        const StartCalendarConnectionState(lifecycle: CalendarConnectionLifecycleState.connectionFailed),
      );
    });
  });

  // Property laws. Each law runs over every history that the model can produce for this command and both hosts.
  final histories = <List<HostSetupEvent>>[
    [],
    [_started],
    [_failed],
    [_failed, _started],
    [_connected],
    [_started, _connected],
    [_started, _failed, _started, _connected],
    [_connected, _busy],
    [_connected, _busy, _busy],
  ];
  final commands = [_command, StartCalendarConnectionCommand(hostId: HostId('bob-employee-id'))];

  // @requires any history and any host
  // @ensures decide yields exactly one started event for the command's host, or throws the already-connected error
  //   in exactly the connected state
  test('decide yields one started event, or rejects only in connected', () async {
    for (final history in histories) {
      final state = _foldHistory(history);
      for (final command in commands) {
        final outcome = await _outcome(command, state);
        if (state.lifecycle == CalendarConnectionLifecycleState.connected) {
          expect(outcome, isA<StartWhenAlreadyConnectedError>(), reason: 'history $history');
        } else {
          expect(outcome, [CalendarConnectionStartedEvent(hostId: command.hostId)], reason: 'history $history');
        }
      }
    }
  });

  // @requires any history where the command is accepted
  // @ensures the emitted events are only events of command.to (calendar_connection_started)
  test('decide emits only calendar_connection_started', () async {
    for (final history in histories) {
      final state = _foldHistory(history);
      final outcome = await _outcome(_command, state);
      if (outcome is List) {
        for (final event in outcome) {
          expect(event, isA<CalendarConnectionStartedEvent>());
        }
      }
    }
  });

  // @requires any accepted command
  // @ensures folding the started event after an accepted decision gives the connecting state
  test('accepted command always leads to connecting', () async {
    for (final history in histories) {
      final state = _foldHistory(history);
      if (state.lifecycle == CalendarConnectionLifecycleState.connected) continue;
      final next = startCalendarConnectionDecider.evolve(state, _started);
      expect(next.lifecycle, CalendarConnectionLifecycleState.connecting);
    }
  });

  // @requires any two commands
  // @ensures equal host ids give equal commands with equal hash codes, and different host ids give unequal commands
  test('command equality and hashCode', () {
    final same = StartCalendarConnectionCommand(hostId: HostId(_host.value));
    expect(same, equals(_command));
    expect(same.hashCode, _command.hashCode);
    expect(commands[1], isNot(equals(_command)));
  });

  // @requires any two states
  // @ensures equal lifecycles give equal states with equal hash codes
  test('state equality and hashCode', () {
    for (final lifecycle in [null, ...CalendarConnectionLifecycleState.values]) {
      final a = StartCalendarConnectionState(lifecycle: lifecycle);
      final b = StartCalendarConnectionState(lifecycle: lifecycle);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    }
  });
}
