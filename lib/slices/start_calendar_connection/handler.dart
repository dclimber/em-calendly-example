import 'package:shelf/shelf.dart';

import '../../platform/web/http.dart';
import '../../ui/paths.dart';
import 'dto.dart';
import 'errors.dart';
import 'service.dart';

/// Handles `connect_calendar`: starts the connection, then returns to the calendar page.
Future<Response> startCalendarConnectionHandler(StartCalendarConnectionService service, FormRequest request) async {
  try {
    await service.handle(startCalendarConnectionCommand(request));
    return noticeRedirect(calendarRoute, 'Connecting your calendar.');
  } on StartCalendarConnectionError catch (error) {
    return errorRedirect(calendarRoute, error.message);
  }
}
