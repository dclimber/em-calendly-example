import 'package:shelf/shelf.dart';

import '../../bounded_contexts/meetings/api.dart';
import '../../platform/web/http.dart';
import '../../ui/paths.dart';
import 'command.dart';
import 'errors.dart';
import 'service.dart';

/// Turns the cancel form into a cancellation request. The meeting id comes from the path; the viewer is the requester.
Future<Response> requestMeetingCancellationHandler(
  RequestMeetingCancellationService service,
  FormRequest request,
) async {
  final meetingId = request.param('meetingId');
  try {
    await service.handle(
      RequestMeetingCancellationCommand(
        meetingId: MeetingId(meetingId),
        requestedBy: RequestedBy(request.viewer.employeeId),
      ),
    );
    return noticeRedirect(meetingDetails(meetingId), 'Your meeting is being canceled.');
  } on RequestMeetingCancellationError catch (error) {
    return errorRedirect(meetingDetails(meetingId), error.message);
  }
}
