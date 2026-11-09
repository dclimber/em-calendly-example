import '../../bounded_contexts/host_setup/api.dart';
import '../../platform/web/http.dart';
import 'command.dart';

final _datePattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

/// The date of the form, `yyyy-MM-dd`, held as UTC midnight. A text that is not a real calendar date is refused.
ExceptionDate _exceptionDate(String text) {
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

/// Builds the command from the form. The form has one date and up to three hour rows, each with a start and an end.
/// A row whose times are both empty is left out. When no row is left, the list is empty, which means that the whole
/// date is unavailable. A row with one time only stays in, and the decider refuses it.
AddDateExceptionCommand addDateExceptionCommand(FormRequest request) {
  final starts = request.all('start_time');
  final ends = request.all('end_time');
  final rows = starts.length > ends.length ? starts.length : ends.length;
  final ranges = <ExceptionHoursRange>[];
  for (var i = 0; i < rows; i++) {
    final start = (i < starts.length ? starts[i] : '').trim();
    final end = (i < ends.length ? ends[i] : '').trim();
    if (start.isEmpty && end.isEmpty) continue;
    ranges.add(ExceptionHoursRange(startTime: start, endTime: end));
  }
  return AddDateExceptionCommand(
    scheduleId: ScheduleId(request.param('scheduleId')),
    hostId: HostId(request.viewer.employeeId),
    exceptionDate: _exceptionDate((request.all('date').firstOrNull ?? '').trim()),
    exceptionHours: ExceptionHours(ranges),
  );
}
