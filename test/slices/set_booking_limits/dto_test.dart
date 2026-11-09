import 'package:em_calendly_example/platform/web/http.dart';
import 'package:em_calendly_example/slices/set_booking_limits/dto.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import '../../support/test_app.dart';

FormRequest _form(Map<String, List<String>> fields) => FormRequest(
  viewer: alice,
  pathParameters: const {'scheduleId': 'schedule-1'},
  fields: fields,
  request: Request('POST', Uri.parse('http://scheduler.test/schedules/schedule-1/limits')),
);

Map<String, List<String>> _fields({
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
  group('setBookingLimitsCommand', () {
    test('the four numbers become the command, and the host is the viewer', () {
      final command = setBookingLimitsCommand(_form(_fields(window: ' 60 ', notice: '0', before: '5', after: '0')));
      expect(command.scheduleId.value, 'schedule-1');
      expect(command.hostId.value, alice.employeeId);
      expect(command.bookingWindowDays.value, 60);
      expect(command.minimumNoticeMinutes.value, 0);
      expect(command.bufferBeforeMinutes.value, 5);
      expect(command.bufferAfterMinutes.value, 0);
    });

    test('a missing number is refused as form input, with its label', () {
      expect(
        () => setBookingLimitsCommand(_form({..._fields(), 'buffer_after_minutes': const []})),
        throwsA(
          isA<FormInputError>().having((e) => e.message, 'message', 'Buffer after (minutes) is required.'),
        ),
      );
    });

    test('a number that is not whole is refused as form input', () {
      expect(
        () => setBookingLimitsCommand(_form(_fields(window: '2.5'))),
        throwsA(
          isA<FormInputError>().having(
            (e) => e.message,
            'message',
            'Booking window (days) must be a whole number.',
          ),
        ),
      );
    });
  });
}
