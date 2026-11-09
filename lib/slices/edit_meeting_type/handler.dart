import 'package:shelf/shelf.dart';

import '../../platform/web/http.dart';
import '../../ui/paths.dart';
import 'dto.dart';
import 'errors.dart';
import 'service.dart';

/// Handles the `edit_meeting_type` form: saves the edit and returns to the meeting types page. A refused input returns
/// to the same form with the message.
Future<Response> editMeetingTypeHandler(EditMeetingTypeService service, FormRequest request) async {
  final formPath = editMeetingType(request.param('meetingTypeId'));
  try {
    await service.handle(editMeetingTypeCommand(request));
    return noticeRedirect(meetingTypesRoute, 'Saving your meeting type.');
  } on EditMeetingTypeError catch (error) {
    return errorRedirect(formPath, error.message);
  } on FormInputError catch (error) {
    return errorRedirect(formPath, error.message);
  }
}
