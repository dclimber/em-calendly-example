import 'package:shelf/shelf.dart';

import '../../platform/web/http.dart';
import '../../ui/paths.dart';
import 'dto.dart';
import 'errors.dart';
import 'service.dart';

/// Handles `remove_date_exception`: removes the exception of the date, then returns to the schedules page with a notice
/// or the refusal message.
Future<Response> removeDateExceptionHandler(RemoveDateExceptionService service, FormRequest request) async {
  try {
    await service.handle(removeDateExceptionCommand(request));
    return noticeRedirect(schedulesRoute, 'Removing the date exception.');
  } on RemoveDateExceptionError catch (error) {
    return errorRedirect(schedulesRoute, error.message);
  } on FormInputError catch (error) {
    return errorRedirect(schedulesRoute, error.message);
  }
}
