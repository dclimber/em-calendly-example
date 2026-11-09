import 'package:shelf/shelf.dart';

import '../../platform/web/http.dart';
import '../../ui/paths.dart';
import 'dto.dart';
import 'errors.dart';
import 'service.dart';

/// Handles `edit_booking_limits`: saves the limits, then returns to the schedules page. A refused input returns to the
/// same form with the message.
Future<Response> setBookingLimitsHandler(SetBookingLimitsService service, FormRequest request) async {
  final formPath = bookingLimits(request.param('scheduleId'));
  try {
    await service.handle(setBookingLimitsCommand(request));
    return noticeRedirect(schedulesRoute, 'Saving your booking limits.');
  } on SetBookingLimitsError catch (error) {
    return errorRedirect(formPath, error.message);
  } on FormInputError catch (error) {
    return errorRedirect(formPath, error.message);
  }
}
