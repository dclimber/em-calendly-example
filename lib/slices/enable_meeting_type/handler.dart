import 'package:shelf/shelf.dart';

import '../../platform/web/http.dart';
import '../../ui/paths.dart';
import 'dto.dart';
import 'errors.dart';
import 'service.dart';

/// Handles `enable_meeting_type`: enables the meeting type, then returns to the meeting types page with a notice or the
/// refusal message.
Future<Response> enableMeetingTypeHandler(EnableMeetingTypeService service, FormRequest request) async {
  try {
    await service.handle(enableMeetingTypeCommand(request));
    return noticeRedirect(meetingTypesRoute, 'Enabling your meeting type.');
  } on EnableMeetingTypeError catch (error) {
    return errorRedirect(meetingTypesRoute, error.message);
  }
}
