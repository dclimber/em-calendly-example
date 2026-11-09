import '../../bounded_contexts/host_setup/api.dart';
import '../../platform/web/http.dart';
import 'command.dart';

final _datePattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

/// A date of the path, `yyyy-MM-dd`, held as UTC midnight. A text that is not a real calendar date is refused.
ExceptionDate exceptionDateFromText(String text) {
  final match = _datePattern.firstMatch(text);
  if (match != null) {
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    final date = DateTime.utc(year, month, day);
    if (date.year == year && date.month == month && date.day == day) return ExceptionDate(date);
  }
  throw const FormInputError('Exception date must be a date in the form yyyy-MM-dd.');
}

/// Builds the command from the request. The button posts no fields: `schedule_id` and `exception_date` are the path
/// parameters, and `host_id` is the signed-in viewer.
RemoveDateExceptionCommand removeDateExceptionCommand(FormRequest request) => RemoveDateExceptionCommand(
  scheduleId: ScheduleId(request.param('scheduleId')),
  hostId: HostId(request.viewer.employeeId),
  exceptionDate: exceptionDateFromText(request.param('date')),
);
