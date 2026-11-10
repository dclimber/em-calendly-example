import 'package:shelf/shelf.dart';

import '../../composition/app_services.dart';
import '../../platform/web/http.dart';
import '../../ui/paths.dart';
import 'errors.dart';
import 'service.dart';

/// Handles the review form: parses the slot, reserves it, and redirects to the booking result or back to the booking
/// page with the model's refusal text.
Future<Response> reserveMeetingSlotHandler(
  ReserveMeetingSlotService service,
  AppServices services,
  FormRequest request,
) async {
  final meetingTypeId = request.param('meetingTypeId');
  final meetingId = services.ids.newId();
  try {
    final start = _instant(request, 'start', 'Slot start');
    final end = _instant(request, 'end', 'Slot end');
    await service.handle(
      ReserveMeetingSlotInput(
        meetingId: meetingId,
        meetingTypeId: meetingTypeId,
        bookerId: request.viewer.employeeId,
        bookerName: request.viewer.name,
        bookerEmail: request.viewer.email,
        slotStart: start,
        slotEnd: end,
        now: services.clock.now(),
      ),
    );
    return noticeRedirect(bookingResult(meetingId), 'Your booking is being confirmed.');
  } on ReserveMeetingSlotError catch (error) {
    return errorRedirect(bookingPage(meetingTypeId), error.message);
  } on FormInputError catch (error) {
    return errorRedirect(bookingPage(meetingTypeId), error.message);
  }
}

DateTime _instant(FormRequest request, String name, String label) {
  final value = DateTime.tryParse(request.requiredField(name, label: label));
  if (value == null) throw FormInputError('$label is not a valid time.');
  return value.toUtc();
}
