import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/record_calendar_connection_failure/record_connection_failure/command.dart';
import 'package:em_calendly_example/slices/record_calendar_connection_failure/record_connection_failure/decider.dart';
import 'package:em_calendly_example/slices/record_calendar_connection_failure/record_connection_failure/state.dart';
import 'package:test/test.dart';

final _hostId = HostId('alice-employee-id');
final _failure = ConnectionFailure('token_revoked');
final _command = RecordConnectionFailureCommand(hostId: _hostId, connectionFailure: _failure);

RecordConnectionFailureState _foldHistory(List<HostSetupEvent> history) =>
    history.fold(recordConnectionFailureDecider.initialState, recordConnectionFailureDecider.evolve);

void main() {
  group('case external_failure', () {
    // @requires the host's calendar connection is connecting
    // @ensures scenario failure_during_connection_is_recorded: the command emits calendar_connection_failed
    test('failure_during_connection_is_recorded', () async {
      final state = _foldHistory([CalendarConnectionStartedEvent(hostId: _hostId)]);
      final events = await recordConnectionFailureDecider.decide(_command, state).toList();
      expect(events, [CalendarConnectionFailedEvent(hostId: _hostId, connectionFailure: _failure)]);
    });

    // @requires the host's calendar connection is connected
    // @ensures scenario lost_access_is_recorded: the command emits calendar_connection_failed
    test('lost_access_is_recorded', () async {
      final state = _foldHistory([
        CalendarConnectionStartedEvent(hostId: _hostId),
        CalendarConnectedEvent(hostId: _hostId, calendarAccount: CalendarAccount('alice@example.com')),
      ]);
      final events = await recordConnectionFailureDecider.decide(_command, state).toList();
      expect(events, [CalendarConnectionFailedEvent(hostId: _hostId, connectionFailure: _failure)]);
    });
  });

  // @requires any lifecycle state, including no history and connection_failed (a gap: the model states the transition
  // only from connecting and connected)
  // @ensures the decider emits exactly one calendar_connection_failed for the host and failure in every state
  test('accepts the command in every lifecycle state', () async {
    final histories = <List<HostSetupEvent>>[
      const [],
      [CalendarConnectionStartedEvent(hostId: _hostId)],
      [CalendarConnectedEvent(hostId: _hostId, calendarAccount: CalendarAccount('alice@example.com'))],
      [CalendarConnectionFailedEvent(hostId: _hostId, connectionFailure: _failure)],
      [HostBusyTimesRecordedEvent(hostId: _hostId, busyIntervals: BusyIntervals(const []))],
    ];
    for (final history in histories) {
      final events = await recordConnectionFailureDecider.decide(_command, _foldHistory(history)).toList();
      expect(
        events,
        [CalendarConnectionFailedEvent(hostId: _hostId, connectionFailure: _failure)],
        reason: 'history: $history',
      );
    }
  });

  // @requires the lifecycle folded from a history
  // @ensures evolve tracks the lifecycle: connecting, connected, connection_failed
  test('evolve tracks the lifecycle', () {
    final d = recordConnectionFailureDecider;
    expect(
      d.evolve(d.initialState, CalendarConnectionStartedEvent(hostId: _hostId)),
      const RecordConnectionFailureState(lifecycle: CalendarConnectionLifecycleState.connecting),
    );
    expect(
      d.evolve(
        d.initialState,
        CalendarConnectedEvent(hostId: _hostId, calendarAccount: CalendarAccount('alice@example.com')),
      ),
      const RecordConnectionFailureState(lifecycle: CalendarConnectionLifecycleState.connected),
    );
    expect(
      d.evolve(d.initialState, CalendarConnectionFailedEvent(hostId: _hostId, connectionFailure: _failure)),
      const RecordConnectionFailureState(lifecycle: CalendarConnectionLifecycleState.connectionFailed),
    );
  });
}
