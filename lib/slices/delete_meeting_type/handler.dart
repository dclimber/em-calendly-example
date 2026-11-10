import 'package:shelf/shelf.dart';

import '../../platform/web/http.dart';
import '../../ui/paths.dart';
import 'dto.dart';
import 'errors.dart';
import 'service.dart';

/// Handles `delete_meeting_type`: deletes the meeting type, then returns to the meeting types page with a notice or the
/// refusal message.
Future<Response> deleteMeetingTypeHandler(DeleteMeetingTypeService service, FormRequest request) async {
  try {
    await service.handle(deleteMeetingTypeCommand(request));
    return noticeRedirect(meetingTypesRoute, 'Deleting your meeting type.');
  } on DeleteMeetingTypeError catch (error) {
    return errorRedirect(meetingTypesRoute, error.message);
  }
}
