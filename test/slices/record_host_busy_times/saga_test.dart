import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/record_host_busy_times/reported_free_busy/state.dart';
import 'package:em_calendly_example/slices/record_host_busy_times/saga.dart';
import 'package:test/test.dart';

final _intervals = BusyIntervals([
  BusyInterval(busyFrom: DateTime.utc(2027, 3, 22, 8, 30), busyUntil: DateTime.utc(2027, 3, 22, 9)),
  BusyInterval(busyFrom: DateTime.utc(2027, 3, 22, 13), busyUntil: DateTime.utc(2027, 3, 22, 14)),
]);

final _reported = ReportedFreeBusyState(hostId: HostId('alice-employee-id'), busyIntervals: _intervals);

void main() {
  // @requires a reported free/busy answer for a host
  // @ensures scenario reported_busy_times_are_recorded: the processor emits one record_busy_times command
  test('reported_busy_times_are_recorded', () async {
    final commands = await freeBusyTranslatorSaga.react(_reported).toList();
    expect(commands, hasLength(1));
    expect(commands.single.hostId, _reported.hostId);
    expect(commands.single.busyIntervals, _intervals);
  });

  // @requires any reported free/busy answer
  // @ensures the processor emits exactly one command that names the same host, with the same intervals in the same order
  test('exactly one command per report, same host and intervals', () async {
    final reports = [
      _reported,
      ReportedFreeBusyState(hostId: HostId('bob-employee-id'), busyIntervals: const BusyIntervals.empty()),
    ];
    for (final reported in reports) {
      final commands = await freeBusyTranslatorSaga.react(reported).toList();
      expect(commands, hasLength(1));
      expect(commands.single.hostId, reported.hostId);
      expect(commands.single.busyIntervals, reported.busyIntervals);
    }
  });
}
