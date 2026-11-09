import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/calendar_connection_status/module.dart';
import 'package:em_calendly_example/slices/start_calendar_connection/module.dart';
import 'package:em_calendly_example/ui/paths.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';

void main() {
  late TestApp t;

  setUp(() async {
    t = TestApp(slices: const [CalendarConnectionStatusSlice(), StartCalendarConnectionSlice()]);
    await t.start();
  });

  // @requires the host has no connection event
  // @ensures the page says that the calendar is not connected and offers the connect button
  test('no_connection_yet shows the connect button', () async {
    final page = await t.get(calendarRoute, as: alice);

    expect(page.statusCode, 200);
    expect(page.body, contains('Your calendar is not connected yet.'));
    expect(page.body, contains(connectCalendarAction));
    expect(page.body, contains('Connect calendar'));
  });

  // @requires the host starts a connection and the calendar gets connected
  // @ensures the page shows the connected calendar and no connect button
  test('connected_calendar_is_shown', () async {
    await t.given([
      CalendarConnectionStartedEvent(hostId: HostId(alice.employeeId)),
      CalendarConnectedEvent(hostId: HostId(alice.employeeId), calendarAccount: CalendarAccount('alice@example.com')),
    ]);
    await t.drain();

    final page = await t.get(calendarRoute, as: alice);

    expect(page.body, contains('alice@example.com'));
    expect(page.body, contains('Your calendar is connected.'));
    expect(page.body, isNot(contains(connectCalendarAction)));
  });

  // @requires the calendar was connected and the connection then failed
  // @ensures the page shows the failure reason and the connect button for a retry
  test('connection_failure_is_visible', () async {
    await t.given([
      CalendarConnectedEvent(hostId: HostId(alice.employeeId), calendarAccount: CalendarAccount('alice@example.com')),
      CalendarConnectionFailedEvent(
        hostId: HostId(alice.employeeId),
        connectionFailure: ConnectionFailure('Consent was denied'),
      ),
    ]);
    await t.drain();

    final page = await t.get(calendarRoute, as: alice);

    expect(page.body, contains('Consent was denied'));
    expect(page.body, contains('The last connection attempt failed.'));
    expect(page.body, contains(connectCalendarAction));
  });

  // @requires another host's calendar is connected
  // @ensures the page of alice does not show bob's connection
  test('the page shows only the viewer own connection', () async {
    await t.given([
      CalendarConnectedEvent(hostId: HostId(bob.employeeId), calendarAccount: CalendarAccount('bob@example.com')),
    ]);
    await t.drain();

    final page = await t.get(calendarRoute, as: alice);

    expect(page.body, contains('Your calendar is not connected yet.'));
    expect(page.body, isNot(contains('bob@example.com')));
  });

  // @requires the host has no connection
  // @ensures the connect button posts start_calendar_connection, which appends calendar_connection_started
  test('connect button posts start_calendar_connection', () async {
    final response = await t.post(connectCalendarAction, {}, as: alice);

    expect(response.redirectPath, calendarRoute);
    expect(t.events.all.map((e) => e.event), [CalendarConnectionStartedEvent(hostId: HostId(alice.employeeId))]);

    await t.drain();
    final page = await t.get(calendarRoute, as: alice);
    expect(page.body, contains('Your calendar is being connected.'));
  });
}
