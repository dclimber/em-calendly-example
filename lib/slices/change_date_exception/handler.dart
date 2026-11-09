import 'package:shelf/shelf.dart';

import '../../platform/web/http.dart';
import '../../ui/paths.dart';
import 'dto.dart';
import 'errors.dart';
import 'service.dart';

/// Handles `change_date_exception`: changes the hours of the exception, then returns to the schedules page. A refused
/// input returns to the same form with the message.
Future<Response> changeDateExceptionHandler(ChangeDateExceptionService service, FormRequest request) async {
  final formPath = changeDateException(request.param('scheduleId'), request.param('date'));
  try {
    await service.handle(changeDateExceptionCommand(request));
    return noticeRedirect(schedulesRoute, 'Saving the changed date exception.');
  } on ChangeDateExceptionError catch (error) {
    return errorRedirect(formPath, error.message);
  } on FormInputError catch (error) {
    return errorRedirect(formPath, error.message);
  }
}
