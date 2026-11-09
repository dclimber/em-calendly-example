import 'package:jaspr/server.dart';

import '../../composition/app_services.dart';
import '../../platform/web/http.dart';
import '../../ui/paths.dart';
import 'dto.dart';
import 'errors.dart';
import 'service.dart';

/// Handles the `new_meeting_type` form: creates the meeting type, or returns the error to the form.
Future<Response> createMeetingTypeHandler(
  CreateMeetingTypeService service,
  AppServices services,
  FormRequest request,
) async {
  final meetingTypeId = services.ids.newId();
  try {
    await service.handle(
      createMeetingTypeCommand(
        request,
        meetingTypeId: meetingTypeId,
        bookingUrl: services.absoluteUrl(bookingPage(meetingTypeId)),
      ),
    );
    return noticeRedirect(meetingTypesRoute, 'Creating your meeting type.');
  } on CreateMeetingTypeError catch (error) {
    return errorRedirect(newMeetingTypeRoute, error.message);
  }
}
