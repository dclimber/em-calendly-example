import '../../bounded_contexts/host_setup/api.dart';
import '../../platform/web/http.dart';
import 'command.dart';

final _datePattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

/// A date of the path or the form, `yyyy-MM-dd`, held as UTC midnight. A text that is not a real calendar date is
/// refused.
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

/// Builds the command from the form. The date is the one in the path, which names the exception being changed. The
/// form repeats it in a read-only field; when the posted date differs from the path, the post is refused. The form has
/// one start and one end per row. A row whose times are both empty is left out. When no row is left, the list is empty,
/// which means that the whole date is unavailable. A row with one time only stays in, and the decider refuses it.
ChangeDateExceptionCommand changeDateExceptionCommand(FormRequest request) {
  final date = exceptionDateFromText(request.param('date'));
  final posted = request.field('date');
  if (posted != null && exceptionDateFromText(posted) != date) {
    throw const FormInputError('The date of the exception cannot be changed here.');
  }
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
  return ChangeDateExceptionCommand(
    scheduleId: ScheduleId(request.param('scheduleId')),
    hostId: HostId(request.viewer.employeeId),
    exceptionDate: date,
    exceptionHours: ExceptionHours(ranges),
  );
}
