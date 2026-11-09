import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/start_calendar_connection/module.dart';
import 'package:em_calendly_example/ui/paths.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';

void main() {
  late TestApp t;

  setUp(() async {
    t = TestApp(slices: const [StartCalendarConnectionSlice()]);
    await t.start();
  });

  // @requires the host has no calendar connection
  // @ensures the form appends calendar_connection_started for the signed-in host and returns to the calendar page
  test('connect calendar posts start_calendar_connection', () async {
    final response = await t.post(connectCalendarAction, {}, as: alice);

    expect(response.redirectPath, calendarRoute);
    expect(response.notice, 'Connecting your calendar.');
    expect(t.events.all.map((e) => e.event), [CalendarConnectionStartedEvent(hostId: HostId(alice.employeeId))]);
  });

  // @requires the host's calendar is connected
  // @ensures the form appends nothing and returns the model's error text to the calendar page
  test('connected calendar is not connected twice', () async {
    await t.given([
      CalendarConnectedEvent(hostId: HostId(alice.employeeId), calendarAccount: CalendarAccount('alice@example.com')),
    ]);

    final response = await t.post(connectCalendarAction, {}, as: alice);

    expect(response.redirectPath, calendarRoute);
    expect(response.error, 'This calendar is already connected.');
    expect(t.events.all.map((e) => e.event), hasLength(1));
  });

  // @requires the host's last connection failed
  // @ensures the retry appends calendar_connection_started after the failure
  test('retry after a failed connection starts again', () async {
    await t.given([
      CalendarConnectionFailedEvent(hostId: HostId(alice.employeeId), connectionFailure: ConnectionFailure('timeout')),
    ]);

    final response = await t.post(connectCalendarAction, {}, as: alice);

    expect(response.notice, 'Connecting your calendar.');
    expect(t.events.all.last.event, CalendarConnectionStartedEvent(hostId: HostId(alice.employeeId)));
  });
}
