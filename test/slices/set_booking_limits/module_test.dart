import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/ui/paths.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';

final _scheduleId = ScheduleId('d17055e6-8851-5fa9-9a58-12d37191a423');
final _path = bookingLimits(_scheduleId.value);

AvailabilityScheduleCreatedEvent _created() => AvailabilityScheduleCreatedEvent(
  scheduleId: _scheduleId,
  hostId: HostId(alice.employeeId),
  scheduleName: ScheduleName('Working hours'),
  timeZone: TimeZone('Europe/Berlin'),
);

Map<String, List<String>> _limits({
  String window = '60',
  String notice = '120',
  String before = '10',
  String after = '15',
}) => {
  'booking_window_days': [window],
  'minimum_notice_minutes': [notice],
  'buffer_before_minutes': [before],
  'buffer_after_minutes': [after],
};

void main() {
  group('happy_path', () {
    test('host_sets_booking_limits saves the limits and returns to the schedules page', () async {
      final t = TestApp();
      await t.given([_created()]);

      final response = await t.post(_path, _limits(), as: alice);

      expect(response.redirectPath, schedulesRoute);
      expect(response.notice, isNotNull);
      expect(response.error, isNull);
      final stored = t.events.all.map((e) => e.event).last;
      expect(
        stored,
        BookingLimitsSetEvent(
          scheduleId: _scheduleId,
          bookingWindowDays: BookingWindowDays(60),
          minimumNoticeMinutes: MinimumNoticeMinutes(120),
          bufferBeforeMinutes: BufferBeforeMinutes(10),
          bufferAfterMinutes: BufferAfterMinutes(15),
        ),
      );
    });
  });

  group('refused_input', () {
    test('a bookers post is refused and nothing is saved', () async {
      final t = TestApp();
      await t.given([_created()]);

      final response = await t.post(_path, _limits(), as: bob);

      expect(response.redirectPath, _path);
      expect(response.error, 'Only the host of this schedule can set its booking limits.');
      expect(t.events.all.map((e) => e.event).whereType<BookingLimitsSetEvent>(), isEmpty);
    });

    test('a schedule that was never created is refused with its message', () async {
      final t = TestApp();
      await t.start();

      final response = await t.post(_path, _limits(), as: alice);

      expect(response.redirectPath, _path);
      expect(response.error, 'This availability schedule does not exist.');
      expect(t.events.all.map((e) => e.event).whereType<BookingLimitsSetEvent>(), isEmpty);
    });

    test('a non-numeric limit returns to the form and saves nothing', () async {
      final t = TestApp();
      await t.given([_created()]);

      final response = await t.post(_path, _limits(notice: 'soon'), as: alice);

      expect(response.redirectPath, _path);
      expect(response.error, 'Minimum notice (minutes) must be a whole number.');
      expect(t.events.all.map((e) => e.event).whereType<BookingLimitsSetEvent>(), isEmpty);
    });
  });

  group('page', () {
    test('the host sees the form prefilled from the latest saved limits', () async {
      final t = TestApp();
      await t.start();
      await t.given([
        _created(),
        BookingLimitsSetEvent(
          scheduleId: _scheduleId,
          bookingWindowDays: BookingWindowDays(30),
          minimumNoticeMinutes: MinimumNoticeMinutes(60),
          bufferBeforeMinutes: BufferBeforeMinutes(5),
          bufferAfterMinutes: BufferAfterMinutes(7),
        ),
        BookingLimitsSetEvent(
          scheduleId: _scheduleId,
          bookingWindowDays: BookingWindowDays(90),
          minimumNoticeMinutes: MinimumNoticeMinutes(240),
          bufferBeforeMinutes: BufferBeforeMinutes(10),
          bufferAfterMinutes: BufferAfterMinutes(20),
        ),
      ]);

      final response = await t.get(_path, as: alice);

      expect(response.statusCode, 200);
      expect(response.body, contains('value="90"'));
      expect(response.body, contains('value="240"'));
      expect(response.body, contains('value="10"'));
      expect(response.body, contains('value="20"'));
      expect(response.body, isNot(contains('value="30"')));
    });

    test('a bookers view shows the refusal, not the form', () async {
      final t = TestApp();
      await t.start();
      await t.given([_created()]);

      final response = await t.get(_path, as: bob);

      expect(response.body, contains('Only the host of this schedule can set its booking limits.'));
      expect(response.body, isNot(contains('name="booking_window_days"')));
    });
  });
}
