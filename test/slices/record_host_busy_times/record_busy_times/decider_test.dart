import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/record_host_busy_times/record_busy_times/command.dart';
import 'package:em_calendly_example/slices/record_host_busy_times/record_busy_times/decider.dart';
import 'package:em_calendly_example/slices/record_host_busy_times/record_busy_times/state.dart';
import 'package:test/test.dart';

final _hostId = HostId('alice-employee-id');
final _intervals = BusyIntervals([
  BusyInterval(busyFrom: DateTime.utc(2027, 3, 22, 8, 30), busyUntil: DateTime.utc(2027, 3, 22, 9)),
]);
final _command = RecordBusyTimesCommand(hostId: _hostId, busyIntervals: _intervals);

void main() {
  // @requires the host's calendar connection is connected
  // @ensures scenario reported_busy_times_are_recorded: the command emits host_busy_times_recorded with the intervals
  test('reported_busy_times_are_recorded', () async {
    final history = [CalendarConnectedEvent(hostId: _hostId, calendarAccount: CalendarAccount('alice@example.com'))];
    final state = history.fold(recordBusyTimesDecider.initialState, recordBusyTimesDecider.evolve);
    final events = await recordBusyTimesDecider.decide(_command, state).toList();
    expect(events, [HostBusyTimesRecordedEvent(hostId: _hostId, busyIntervals: _intervals)]);
  });

  // @requires any lifecycle state, including no history (a gap: the model states the transition only from connected)
  // @ensures the decider emits exactly one host_busy_times_recorded in every state, with the command's intervals
  test('accepts the command in every lifecycle state', () async {
    final histories = <List<HostSetupEvent>>[
      const [],
      [CalendarConnectionStartedEvent(hostId: _hostId)],
      [CalendarConnectedEvent(hostId: _hostId, calendarAccount: CalendarAccount('alice@example.com'))],
      [CalendarConnectionFailedEvent(hostId: _hostId, connectionFailure: ConnectionFailure('timeout'))],
    ];
    for (final history in histories) {
      final state = history.fold(recordBusyTimesDecider.initialState, recordBusyTimesDecider.evolve);
      final events = await recordBusyTimesDecider.decide(_command, state).toList();
      expect(events, hasLength(1), reason: 'history: $history');
      expect(events.single, isA<HostBusyTimesRecordedEvent>());
      expect((events.single as HostBusyTimesRecordedEvent).busyIntervals, _intervals, reason: 'history: $history');
    }
  });

  // @requires the lifecycle folded from a history
  // @ensures evolve tracks the lifecycle: connecting, connected (also after busy times), connection_failed
  test('evolve tracks the lifecycle', () {
    final d = recordBusyTimesDecider;
    expect(
      d.evolve(d.initialState, CalendarConnectionStartedEvent(hostId: _hostId)),
      const RecordBusyTimesState(lifecycle: CalendarConnectionLifecycleState.connecting),
    );
    expect(
      d.evolve(d.initialState, CalendarConnectedEvent(hostId: _hostId, calendarAccount: CalendarAccount('a'))),
      const RecordBusyTimesState(lifecycle: CalendarConnectionLifecycleState.connected),
    );
    expect(
      d.evolve(d.initialState, HostBusyTimesRecordedEvent(hostId: _hostId, busyIntervals: _intervals)),
      const RecordBusyTimesState(lifecycle: CalendarConnectionLifecycleState.connected),
    );
    expect(
      d.evolve(
        d.initialState,
        CalendarConnectionFailedEvent(hostId: _hostId, connectionFailure: ConnectionFailure('timeout')),
      ),
      const RecordBusyTimesState(lifecycle: CalendarConnectionLifecycleState.connectionFailed),
    );
  });
}
