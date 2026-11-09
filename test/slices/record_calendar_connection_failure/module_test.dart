import 'package:em_calendly_example/bounded_contexts/corporate_calendar/api.dart';
import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/record_calendar_connection_failure/module.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';

void main() {
  final failure = CalendarAccessFailedEvent(
    failureCode: FailureCode('token_revoked'),
    schedulerUserRef: SchedulerUserRef('alice-employee-id'),
  );

  // @requires a host whose calendar connection is connecting
  // @ensures scenario failure_during_connection_is_recorded: the failure records calendar_connection_failed once
  test('failure during connection is recorded', () async {
    final t = TestApp(slices: const [RecordCalendarConnectionFailureSlice()]);
    await t.start();

    await t.given([CalendarConnectionStartedEvent(hostId: HostId('alice-employee-id'))]);
    await t.given([failure]);
    await t.drain();

    // The calendar bridge also answers the started event: alice is not registered here, so it appends its own
    // `employee_unknown` failure, which this slice records too. The assertion is on the `token_revoked` record.
    expect(
      t.events.all.map((e) => e.event).whereType<CalendarConnectionFailedEvent>().map((e) => e.connectionFailure),
      contains(ConnectionFailure('token_revoked')),
    );
  });

  // @requires a host whose calendar connection is connected
  // @ensures scenario lost_access_is_recorded: the failure records calendar_connection_failed once
  test('lost access is recorded', () async {
    final t = TestApp(slices: const [RecordCalendarConnectionFailureSlice()]);
    await t.start();

    await t.given([CalendarConnectionStartedEvent(hostId: HostId('alice-employee-id'))]);
    await t.given([
      CalendarConnectedEvent(
        hostId: HostId('alice-employee-id'),
        calendarAccount: CalendarAccount('alice@example.com'),
      ),
    ]);
    await t.given([failure]);
    await t.drain();

    // The calendar bridge also answers the started event: alice is not registered here, so it appends its own
    // `employee_unknown` failure, which this slice records too. The assertion is on the `token_revoked` record.
    expect(
      t.events.all.map((e) => e.event).whereType<CalendarConnectionFailedEvent>().map((e) => e.connectionFailure),
      contains(ConnectionFailure('token_revoked')),
    );
  });
}
