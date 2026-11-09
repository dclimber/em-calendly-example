import 'package:em_calendly_example/bounded_contexts/corporate_calendar/api.dart';
import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/record_host_busy_times/reported_free_busy/view.dart';
import 'package:test/test.dart';

final _reported = FreeBusyReportedEvent(
  schedulerUserRef: SchedulerUserRef('alice-employee-id'),
  freeBusyBlocks: FreeBusyBlocks([
    FreeBusyBlock(busyFrom: DateTime.utc(2027, 3, 22, 8, 30), busyUntil: DateTime.utc(2027, 3, 22, 9)),
    FreeBusyBlock(busyFrom: DateTime.utc(2027, 3, 22, 13), busyUntil: DateTime.utc(2027, 3, 22, 14)),
  ]),
);

void main() {
  // @requires a free_busy_reported event
  // @ensures scenario report_is_listed: the view holds the host id and the busy intervals of the report, in order
  test('report_is_listed', () {
    final state = reportedFreeBusyView.evolve(reportedFreeBusyView.initialState, _reported);
    expect(state, isNotNull);
    expect(state!.hostId, HostId('alice-employee-id'));
    expect(
      state.busyIntervals,
      BusyIntervals([
        BusyInterval(busyFrom: DateTime.utc(2027, 3, 22, 8, 30), busyUntil: DateTime.utc(2027, 3, 22, 9)),
        BusyInterval(busyFrom: DateTime.utc(2027, 3, 22, 13), busyUntil: DateTime.utc(2027, 3, 22, 14)),
      ]),
    );
  });

  // @requires a free_busy_reported event with no blocks (the model states no rule for an empty report)
  // @ensures the view holds the host id and no busy intervals
  test('empty report lists the host with no intervals', () {
    final empty = FreeBusyReportedEvent(
      schedulerUserRef: SchedulerUserRef('alice-employee-id'),
      freeBusyBlocks: const FreeBusyBlocks.empty(),
    );
    final state = reportedFreeBusyView.evolve(reportedFreeBusyView.initialState, empty);
    expect(state!.busyIntervals, const BusyIntervals.empty());
  });

  // @requires no event
  // @ensures the view is empty before any report
  test('empty before any report', () {
    expect(reportedFreeBusyView.initialState, isNull);
  });
}
