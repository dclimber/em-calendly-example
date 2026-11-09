import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/slices/my_availability_schedules/state.dart';
import 'package:em_calendly_example/slices/my_availability_schedules/view.dart';
import 'package:test/test.dart';

import '../../support/samples/host_setup_samples.dart';

final _schedule = ScheduleId('sched-1');
final _alice = HostId('alice-employee-id');
final _christmas = DateTime.utc(2026, 12, 24);

final _created = AvailabilityScheduleCreatedEvent(
  scheduleId: _schedule,
  hostId: _alice,
  scheduleName: ScheduleName('Working hours'),
  timeZone: TimeZone('Europe/Berlin'),
);
final _weeklyHours = WeeklyHoursSetEvent(
  scheduleId: _schedule,
  weeklyHours: WeeklyHours([WeeklyHoursEntry(weekday: 'monday', startTime: '09:00', endTime: '17:00')]),
);
final _limits = BookingLimitsSetEvent(
  scheduleId: _schedule,
  bookingWindowDays: BookingWindowDays(60),
  minimumNoticeMinutes: MinimumNoticeMinutes(240),
  bufferBeforeMinutes: BufferBeforeMinutes(5),
  bufferAfterMinutes: BufferAfterMinutes(10),
);
final _added = DateExceptionAddedEvent(
  scheduleId: _schedule,
  exceptionDate: ExceptionDate(_christmas),
  exceptionHours: ExceptionHours([ExceptionHoursRange(startTime: '10:00', endTime: '12:00')]),
);
final _changed = DateExceptionChangedEvent(
  scheduleId: _schedule,
  exceptionDate: ExceptionDate(_christmas),
  exceptionHours: const ExceptionHours.empty(),
);
final _removed = DateExceptionRemovedEvent(scheduleId: _schedule, exceptionDate: ExceptionDate(_christmas));

AvailabilitySchedule? _fold(List<HostSetupEvent> events) =>
    events.fold<AvailabilitySchedule?>(availabilitySchedulesView.initialState, availabilitySchedulesView.evolve);

AvailabilitySchedule _schedulePlain() => AvailabilitySchedule(
  scheduleId: _schedule,
  hostId: _alice,
  scheduleName: ScheduleName('Working hours'),
  timeZone: TimeZone('Europe/Berlin'),
);

void main() {
  // @requires the host has no schedule
  // @ensures the view has no document
  test('no_schedule_yet', () {
    expect(_fold([]), isNull);
  });

  // @requires the schedule is created
  // @ensures the schedule appears with empty weekly hours, no exceptions and no booking limits
  test('new_schedule_appears', () {
    expect(_fold([_created]), _schedulePlain());
  });

  // @requires the schedule is created, its weekly hours are set and its booking limits are set
  // @ensures the schedule shows the weekly hours and the booking limits
  test('rules_update_the_schedule', () {
    final expected = AvailabilitySchedule(
      scheduleId: _schedule,
      hostId: _alice,
      scheduleName: ScheduleName('Working hours'),
      timeZone: TimeZone('Europe/Berlin'),
      weeklyHours: WeeklyHours([WeeklyHoursEntry(weekday: 'monday', startTime: '09:00', endTime: '17:00')]),
      bookingWindowDays: BookingWindowDays(60),
      minimumNoticeMinutes: MinimumNoticeMinutes(240),
      bufferBeforeMinutes: BufferBeforeMinutes(5),
      bufferAfterMinutes: BufferAfterMinutes(10),
    );
    expect(_fold([_created, _weeklyHours, _limits]), expected);
  });

  // @requires an exception is added and then changed to empty hours
  // @ensures the date keeps its exception with the new hours
  test('changed_exception_updates_the_schedule', () {
    final state = _fold([_created, _added, _changed])!;
    expect(state.dateExceptions.items, [DateException(exceptionDate: _christmas, hours: const ExceptionHours.empty())]);
  });

  // @requires an exception is added and then removed
  // @ensures the date leaves the list of exceptions
  test('removed_exception_leaves_the_schedule', () {
    final state = _fold([_created, _added, _removed])!;
    expect(state.dateExceptions.items, isEmpty);
  });

  // @requires events of a schedule that was never created
  // @ensures no document is created
  test('events_before_creation_change_nothing', () {
    expect(_fold([_weeklyHours, _added, _limits]), isNull);
  });

  // @requires the same exception is added twice
  // @ensures the second add changes nothing (one entry per date)
  test('adding_the_same_date_twice_is_idempotent', () {
    expect(_fold([_created, _added, _added]), _fold([_created, _added]));
  });

  // @requires any state
  // @ensures the state survives a JSON round trip unchanged
  test('json_round_trip_is_lossless', () {
    final state = _fold([_created, _weeklyHours, _added, _limits])!;
    expect(AvailabilitySchedule.fromJson(state.toJson()), state);
  });

  // @requires events of other host_setup flows
  // @ensures the view state does not change
  test('evolve_ignores_events_outside_the_slice', () {
    final states = <AvailabilitySchedule?>[
      null,
      _fold([_created, _added]),
    ];
    final others = sampleHostSetupEvents().where(
      (e) =>
          e is! AvailabilityScheduleCreatedEvent &&
          e is! WeeklyHoursSetEvent &&
          e is! DateExceptionAddedEvent &&
          e is! DateExceptionChangedEvent &&
          e is! DateExceptionRemovedEvent &&
          e is! BookingLimitsSetEvent,
    );
    for (final state in states) {
      for (final event in others) {
        expect(availabilitySchedulesView.evolve(state, event), state, reason: '$event');
      }
    }
  });
}
