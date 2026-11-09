import 'package:em_calendly_example/bounded_contexts/corporate_calendar/api.dart';
import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/record_calendar_connected/module.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';

void main() {
  final grant = CalendarAccessGrantedEvent(
    schedulerUserRef: SchedulerUserRef('alice-employee-id'),
    calendarAccount: 'alice@example.com',
  );

  // @requires a host whose calendar connection is connecting
  // @ensures the granted access records calendar_connected once, for the host and the account
  test('granted access records calendar_connected', () async {
    final t = TestApp(slices: const [RecordCalendarConnectedSlice()]);
    await t.start();

    await t.given([CalendarConnectionStartedEvent(hostId: HostId('alice-employee-id'))]);
    await t.given([grant]);
    await t.drain();

    expect(
      t.events.all.map((e) => e.event).whereType<CalendarConnectedEvent>(),
      [
        CalendarConnectedEvent(
          hostId: HostId('alice-employee-id'),
          calendarAccount: CalendarAccount('alice@example.com'),
        ),
      ],
    );
  });
}
