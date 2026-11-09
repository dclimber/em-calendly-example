import '../../bounded_contexts/host_setup/api.dart';
import '../../platform/web/http.dart';
import 'command.dart';

const _weekdays = {'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'};

/// Builds the command from the form. Each row is one weekday with a start and an end. A row whose times are both
/// empty means no hours that day, so it is left out. A row with one time only stays in, and the decider refuses it.
SetWeeklyHoursCommand setWeeklyHoursCommand(FormRequest request) {
  final weekdays = request.all('weekday');
  final starts = request.all('start_time');
  final ends = request.all('end_time');
  final entries = <WeeklyHoursEntry>[];
  for (var i = 0; i < weekdays.length; i++) {
    final weekday = weekdays[i].trim();
    final start = (i < starts.length ? starts[i] : '').trim();
    final end = (i < ends.length ? ends[i] : '').trim();
    if (start.isEmpty && end.isEmpty) continue;
    if (!_weekdays.contains(weekday)) throw const FormInputError('Weekday must be a day of the week.');
    entries.add(WeeklyHoursEntry(weekday: weekday, startTime: start, endTime: end));
  }
  return SetWeeklyHoursCommand(
    scheduleId: ScheduleId(request.param('scheduleId')),
    hostId: HostId(request.viewer.employeeId),
    weeklyHours: WeeklyHours(entries),
  );
}
