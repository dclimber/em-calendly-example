import 'package:shelf/shelf.dart';

import '../../platform/web/http.dart';
import '../../ui/paths.dart';
import 'dto.dart';
import 'errors.dart';
import 'service.dart';

/// Handles `edit_weekly_hours`: saves the hours, then returns to the schedules page. A refused input returns to the
/// same form with the message.
Future<Response> setWeeklyHoursHandler(SetWeeklyHoursService service, FormRequest request) async {
  final formPath = weeklyHours(request.param('scheduleId'));
  try {
    await service.handle(setWeeklyHoursCommand(request));
    return noticeRedirect(schedulesRoute, 'Saving your weekly hours.');
  } on SetWeeklyHoursError catch (error) {
    return errorRedirect(formPath, error.message);
  } on FormInputError catch (error) {
    return errorRedirect(formPath, error.message);
  }
}
