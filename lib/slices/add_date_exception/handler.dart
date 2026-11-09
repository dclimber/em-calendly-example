import 'package:shelf/shelf.dart';

import '../../platform/web/http.dart';
import '../../ui/paths.dart';
import 'dto.dart';
import 'errors.dart';
import 'service.dart';

/// Handles `add_date_exception`: adds the exception, then returns to the schedules page. A refused input returns to
/// the same form with the message.
Future<Response> addDateExceptionHandler(AddDateExceptionService service, FormRequest request) async {
  final formPath = newDateException(request.param('scheduleId'));
  try {
    await service.handle(addDateExceptionCommand(request));
    return noticeRedirect(schedulesRoute, 'Saving the date exception.');
  } on AddDateExceptionError catch (error) {
    return errorRedirect(formPath, error.message);
  } on FormInputError catch (error) {
    return errorRedirect(formPath, error.message);
  }
}
