import 'package:shelf/shelf.dart';

import '../../composition/app_services.dart';
import '../../platform/web/http.dart';
import '../../ui/paths.dart';
import 'errors.dart';
import 'service.dart';

/// Turns the confirm form into a reschedule. The new slot arrives as UTC instants in `start` and `end`.
Future<Response> requestMeetingRescheduleHandler(
  RequestMeetingRescheduleService service,
  AppServices services,
  FormRequest request,
) async {
  final meetingId = request.param('meetingId');
  try {
    final start = _instant(request, 'start', 'New slot start');
    final end = _instant(request, 'end', 'New slot end');
    await service.handle(
      RequestMeetingRescheduleInput(
        meetingId: meetingId,
        requestedBy: request.viewer.employeeId,
        newSlotStart: start,
        newSlotEnd: end,
        now: services.clock.now(),
      ),
    );
    return noticeRedirect(meetingDetails(meetingId), 'Your new time is being confirmed.');
  } on RequestMeetingRescheduleError catch (error) {
    return errorRedirect(rescheduleSlotPicker(meetingId), error.message);
  } on FormInputError catch (error) {
    return errorRedirect(rescheduleSlotPicker(meetingId), error.message);
  }
}

DateTime _instant(FormRequest request, String name, String label) {
  final value = DateTime.tryParse(request.requiredField(name, label: label));
  if (value == null) throw FormInputError('$label is not a valid time.');
  return value.toUtc();
}
