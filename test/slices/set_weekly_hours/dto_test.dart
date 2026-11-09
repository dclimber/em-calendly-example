import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/platform/web/http.dart';
import 'package:em_calendly_example/slices/set_weekly_hours/dto.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';

FormRequest _form(Map<String, List<String>> fields) => FormRequest(
  viewer: alice,
  pathParameters: const {'scheduleId': 'schedule-1'},
  fields: fields,
  request: Request('POST', Uri.parse('http://scheduler.test/schedules/schedule-1/weekly-hours')),
);

void main() {
  group('setWeeklyHoursCommand', () {
    test('rows with no times are left out, and the rest keep their order', () {
      final command = setWeeklyHoursCommand(
        _form({
          'weekday': ['Monday', 'Tuesday', 'Friday'],
          'start_time': ['09:00', '', '09:00'],
          'end_time': ['17:00', '', '13:00'],
        }),
      );
      expect(command.weeklyHours.items.map((e) => e.weekday), ['Monday', 'Friday']);
      expect(command.hostId.value, alice.employeeId);
      expect(command.scheduleId.value, 'schedule-1');
    });

    test('a row with one time stays in, for the decider to refuse', () {
      final command = setWeeklyHoursCommand(
        _form({
          'weekday': ['Monday'],
          'start_time': ['09:00'],
          'end_time': [''],
        }),
      );
      expect(command.weeklyHours.items, [WeeklyHoursEntry(weekday: 'Monday', startTime: '09:00', endTime: '')]);
    });

    test('an unknown weekday is refused as form input', () {
      expect(
        () => setWeeklyHoursCommand(
          _form({
            'weekday': ['Funday'],
            'start_time': ['09:00'],
            'end_time': ['10:00'],
          }),
        ),
        throwsA(isA<FormInputError>()),
      );
    });

    test('no rows with times gives no hours', () {
      final command = setWeeklyHoursCommand(
        _form({
          'weekday': ['Monday', 'Tuesday'],
          'start_time': ['', ''],
          'end_time': ['', ''],
        }),
      );
      expect(command.weeklyHours.items, isEmpty);
    });
  });
}
