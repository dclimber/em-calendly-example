import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/platform/time/clock.dart';
import 'package:em_calendly_example/slices/create_availability_schedule/module.dart';
import 'package:em_calendly_example/ui/paths.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';

void main() {
  late TestApp t;

  setUp(() async {
    t = TestApp(
      slices: const [CreateAvailabilityScheduleSlice()],
      ids: SequenceIdGenerator(['schedule-1']),
    );
    await t.start();
  });

  // @requires alice is signed in
  // @ensures the page offers the schedule name and the time zone, defaulting to Europe/Berlin, posted to the schedules
  test('new schedule page renders the form', () async {
    final response = await t.get(newScheduleRoute, as: alice);

    expect(response.statusCode, 200);
    expect(response.body, contains('name="schedule_name"'));
    expect(response.body, contains('name="time_zone"'));
    expect(response.body, contains('value="Europe/Berlin"'));
    expect(response.body, contains('action="$schedulesRoute"'));
  });

  // @requires alice submits a name and a time zone
  // @ensures the form appends availability_schedule_created for alice with the generated schedule id, then returns to
  //   the schedules page with a notice
  test('post creates the schedule and redirects to the schedules page', () async {
    final response = await t.post(schedulesRoute, {
      'schedule_name': 'Working hours',
      'time_zone': 'Europe/Berlin',
    }, as: alice);

    expect(response.redirectPath, schedulesRoute);
    expect(response.notice, 'Creating your availability schedule.');
    expect(t.events.all.map((e) => e.event), [
      AvailabilityScheduleCreatedEvent(
        scheduleId: ScheduleId('schedule-1'),
        hostId: HostId(alice.employeeId),
        scheduleName: ScheduleName('Working hours'),
        timeZone: TimeZone('Europe/Berlin'),
      ),
    ]);
  });

  // @requires alice leaves the schedule name empty
  // @ensures the form appends nothing and returns the input error to the schedules page
  test('missing schedule name appends nothing', () async {
    final response = await t.post(schedulesRoute, {'schedule_name': ' ', 'time_zone': 'Europe/Berlin'}, as: alice);

    expect(response.error, 'Schedule name is required.');
    expect(t.events.all, isEmpty);
  });
}
