import 'package:em_calendly_example/bounded_contexts/corporate_calendar/api.dart';
import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/record_host_busy_times/module.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';

void main() {
  final reported = FreeBusyReportedEvent(
    schedulerUserRef: SchedulerUserRef('alice-employee-id'),
    freeBusyBlocks: FreeBusyBlocks([
      FreeBusyBlock(busyFrom: DateTime.utc(2027, 3, 22, 8, 30), busyUntil: DateTime.utc(2027, 3, 22, 9)),
    ]),
  );

  // @requires a host whose calendar connection is connected
  // @ensures the reported free/busy data records host_busy_times_recorded once, for the host and its intervals
  test('reported free/busy records host_busy_times_recorded', () async {
    final t = TestApp(slices: const [RecordHostBusyTimesSlice()]);
    await t.start();

    await t.given([CalendarConnectedEvent(hostId: HostId('alice-employee-id'), calendarAccount: CalendarAccount('a'))]);
    await t.given([reported]);
    await t.drain();

    expect(t.events.all.map((e) => e.event).whereType<HostBusyTimesRecordedEvent>(), [
      HostBusyTimesRecordedEvent(
        hostId: HostId('alice-employee-id'),
        busyIntervals: BusyIntervals([
          BusyInterval(busyFrom: DateTime.utc(2027, 3, 22, 8, 30), busyUntil: DateTime.utc(2027, 3, 22, 9)),
        ]),
      ),
    ]);
  });

  // @requires a free_busy_reported event for a host with no calendar connection (a gap: no rule in the model)
  // @ensures the decider still records the busy intervals, as the command has no invalid transition
  test('report without a connection is still recorded', () async {
    final t = TestApp(slices: const [RecordHostBusyTimesSlice()]);
    await t.start();

    await t.given([reported]);
    await t.drain();

    expect(t.events.all.map((e) => e.event).whereType<HostBusyTimesRecordedEvent>(), hasLength(1));
  });
}
