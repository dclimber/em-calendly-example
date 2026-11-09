import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/ui/paths.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';

final _scheduleId = ScheduleId('d17055e6-8851-5fa9-9a58-12d37191a423');
final _actionPath = removeDateException(_scheduleId.value, '2027-03-24');

AvailabilityScheduleCreatedEvent _created({String? hostId}) => AvailabilityScheduleCreatedEvent(
  scheduleId: _scheduleId,
  hostId: HostId(hostId ?? alice.employeeId),
  scheduleName: ScheduleName('Working hours'),
  timeZone: TimeZone('Europe/Berlin'),
);

DateExceptionAddedEvent _added() => DateExceptionAddedEvent(
  scheduleId: _scheduleId,
  exceptionDate: ExceptionDate(DateTime.utc(2027, 3, 24)),
  exceptionHours: ExceptionHours([ExceptionHoursRange(startTime: '09:00', endTime: '12:00')]),
);

Iterable<DateExceptionRemovedEvent> _removedEvents(TestApp t) =>
    t.events.all.map((e) => e.event).whereType<DateExceptionRemovedEvent>();

void main() {
  group('happy_path', () {
    test('host_removes_an_exception removes the exception and returns to the schedules page', () async {
      final t = TestApp();
      await t.given([_created(), _added()]);

      final response = await t.post(_actionPath, {}, as: alice);

      expect(response.redirectPath, schedulesRoute);
      expect(response.notice, isNotNull);
      expect(_removedEvents(t).single.exceptionDate, ExceptionDate(DateTime.utc(2027, 3, 24)));
      expect(_removedEvents(t).single.scheduleId, _scheduleId);
    });
  });

  group('refused', () {
    test('a removal by someone other than the host returns to the schedules page with the message', () async {
      final t = TestApp();
      await t.given([_created(), _added()]);

      final response = await t.post(_actionPath, {}, as: bob);

      expect(response.redirectPath, schedulesRoute);
      expect(response.error, 'Only the host of this schedule can remove a date exception.');
      expect(_removedEvents(t), isEmpty);
    });

    test('a schedule that was never created is refused and nothing is saved', () async {
      final t = TestApp();
      await t.start();

      final response = await t.post(_actionPath, {}, as: alice);

      expect(response.redirectPath, schedulesRoute);
      expect(response.error, 'This availability schedule does not exist.');
      expect(_removedEvents(t), isEmpty);
    });

    test('a path date that is not a real date is refused and nothing is saved', () async {
      final t = TestApp();
      await t.given([_created(), _added()]);

      final response = await t.post(removeDateException(_scheduleId.value, '2027-02-30'), {}, as: alice);

      expect(response.redirectPath, schedulesRoute);
      expect(response.error, 'Exception date must be a date in the form yyyy-MM-dd.');
      expect(_removedEvents(t), isEmpty);
    });
  });
}
