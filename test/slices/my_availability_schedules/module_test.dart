import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/my_availability_schedules/module.dart';
import 'package:em_calendly_example/ui/format.dart';
import 'package:em_calendly_example/ui/paths.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';

final _schedule = ScheduleId('sched-1');
final _christmas = DateTime.utc(2026, 12, 24);
final _iso = isoDate(_christmas);

AvailabilityScheduleCreatedEvent _created({HostId? host, String name = 'Working hours'}) =>
    AvailabilityScheduleCreatedEvent(
      scheduleId: _schedule,
      hostId: host ?? HostId('alice-employee-id'),
      scheduleName: ScheduleName(name),
      timeZone: TimeZone('Europe/Berlin'),
    );

void main() {
  late TestApp t;

  setUp(() async {
    t = TestApp(slices: const [MyAvailabilitySchedulesSlice()]);
    await t.start();
  });

  // @requires the host has no schedule
  // @ensures the page says there are no schedules and offers the new schedule button
  test('no_schedule_yet shows the empty state', () async {
    final page = await t.get(schedulesRoute, as: alice);

    expect(page.statusCode, 200);
    expect(page.body, contains('You have no availability schedules yet.'));
    expect(page.body, contains(newScheduleRoute));
  });

  // @requires the schedule is created
  // @ensures the page shows the schedule with its links to the rules
  test('new_schedule_appears', () async {
    await t.given([_created()]);
    await t.drain();

    final page = await t.get(schedulesRoute, as: alice);

    expect(page.body, contains('Working hours'));
    expect(page.body, contains('Europe/Berlin'));
    expect(page.body, contains(weeklyHours(_schedule.value)));
    expect(page.body, contains(bookingLimits(_schedule.value)));
    expect(page.body, contains(newDateException(_schedule.value)));
    expect(page.body, contains('Not set yet'));
  });

  // @requires the weekly hours and the booking limits are set
  // @ensures the page shows the rules
  test('rules_update_the_schedule', () async {
    await t.given([
      _created(),
      WeeklyHoursSetEvent(
        scheduleId: _schedule,
        weeklyHours: WeeklyHours([WeeklyHoursEntry(weekday: 'monday', startTime: '09:00', endTime: '17:00')]),
      ),
      BookingLimitsSetEvent(
        scheduleId: _schedule,
        bookingWindowDays: BookingWindowDays(60),
        minimumNoticeMinutes: MinimumNoticeMinutes(240),
        bufferBeforeMinutes: BufferBeforeMinutes(5),
        bufferAfterMinutes: BufferAfterMinutes(10),
      ),
    ]);
    await t.drain();

    final page = await t.get(schedulesRoute, as: alice);

    expect(page.body, contains('monday 09:00-17:00'));
    expect(page.body, contains('60 days ahead, 240 min notice, 5 min buffer before, 10 min buffer after'));
  });

  // @requires an exception is added and then changed to empty hours
  // @ensures the page shows the date as unavailable with change and remove actions
  test('changed_exception_updates_the_schedule', () async {
    await t.given([
      _created(),
      DateExceptionAddedEvent(
        scheduleId: _schedule,
        exceptionDate: ExceptionDate(_christmas),
        exceptionHours: ExceptionHours([ExceptionHoursRange(startTime: '10:00', endTime: '12:00')]),
      ),
      DateExceptionChangedEvent(
        scheduleId: _schedule,
        exceptionDate: ExceptionDate(_christmas),
        exceptionHours: const ExceptionHours.empty(),
      ),
    ]);
    await t.drain();

    final page = await t.get(schedulesRoute, as: alice);

    expect(page.body, contains(_iso));
    expect(page.body, contains('Unavailable all day'));
    expect(page.body, contains(changeDateException(_schedule.value, _iso)));
    expect(page.body, contains(removeDateException(_schedule.value, _iso)));
  });

  // @requires an exception is added and then removed
  // @ensures the date no longer appears among the exceptions
  test('removed_exception_leaves_the_schedule', () async {
    await t.given([
      _created(),
      DateExceptionAddedEvent(
        scheduleId: _schedule,
        exceptionDate: ExceptionDate(_christmas),
        exceptionHours: ExceptionHours([ExceptionHoursRange(startTime: '10:00', endTime: '12:00')]),
      ),
      DateExceptionRemovedEvent(scheduleId: _schedule, exceptionDate: ExceptionDate(_christmas)),
    ]);
    await t.drain();

    final page = await t.get(schedulesRoute, as: alice);

    expect(page.body, contains('No date exceptions.'));
    expect(page.body, isNot(contains(removeDateException(_schedule.value, _iso))));
  });

  // @requires another host has a schedule
  // @ensures alice does not see the schedule of bob
  test('only_the_viewers_schedules_are_shown', () async {
    await t.given([_created(host: HostId('bob-employee-id'), name: 'Bobs hours')]);
    await t.drain();

    final page = await t.get(schedulesRoute, as: alice);

    expect(page.body, isNot(contains('Bobs hours')));
    expect(page.body, contains('You have no availability schedules yet.'));
  });
}
