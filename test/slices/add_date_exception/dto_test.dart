import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/platform/web/http.dart';
import 'package:em_calendly_example/slices/add_date_exception/dto.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';

FormRequest _form(Map<String, List<String>> fields) => FormRequest(
  viewer: alice,
  pathParameters: const {'scheduleId': 'schedule-1'},
  fields: fields,
  request: Request('POST', Uri.parse('http://scheduler.test/schedules/schedule-1/exceptions')),
);

void main() {
  group('addDateExceptionCommand', () {
    test('the date is read as UTC midnight, and the schedule and host come from the request', () {
      final command = addDateExceptionCommand(
        _form({
          'date': ['2027-03-24'],
          'start_time': [''],
          'end_time': [''],
        }),
      );
      expect(command.exceptionDate, ExceptionDate(DateTime.utc(2027, 3, 24)));
      expect(command.scheduleId.value, 'schedule-1');
      expect(command.hostId.value, alice.employeeId);
    });

    test('rows with no times are left out, and the rest keep their order', () {
      final command = addDateExceptionCommand(
        _form({
          'date': ['2027-03-24'],
          'start_time': ['09:00', '', '13:00'],
          'end_time': ['12:00', '', '15:30'],
        }),
      );
      expect(command.exceptionHours.items, [
        ExceptionHoursRange(startTime: '09:00', endTime: '12:00'),
        ExceptionHoursRange(startTime: '13:00', endTime: '15:30'),
      ]);
    });

    test('no rows with times gives no hours, which makes the whole date unavailable', () {
      final command = addDateExceptionCommand(
        _form({
          'date': ['2027-03-24'],
          'start_time': ['', '', ''],
          'end_time': ['', '', ''],
        }),
      );
      expect(command.exceptionHours.items, isEmpty);
    });

    test('a row with one time stays in, for the decider to refuse', () {
      final command = addDateExceptionCommand(
        _form({
          'date': ['2027-03-24'],
          'start_time': ['09:00'],
          'end_time': [''],
        }),
      );
      expect(command.exceptionHours.items, [ExceptionHoursRange(startTime: '09:00', endTime: '')]);
    });

    test('a missing date is refused as form input', () {
      expect(
        () => addDateExceptionCommand(
          _form({
            'start_time': [''],
            'end_time': [''],
          }),
        ),
        throwsA(isA<FormInputError>()),
      );
    });

    test('a date that is not a real calendar day is refused as form input', () {
      for (final text in ['2027-02-30', '24.03.2027', '2027-3-24', '']) {
        expect(
          () => addDateExceptionCommand(
            _form({
              'date': [text],
              'start_time': [''],
              'end_time': [''],
            }),
          ),
          throwsA(isA<FormInputError>()),
          reason: text,
        );
      }
    });
  });
}
