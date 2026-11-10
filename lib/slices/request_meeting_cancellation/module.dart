import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../ui/paths.dart';
import 'handler.dart';
import 'service.dart';
import 'ui/confirm_cancellation_page.dart';

final class RequestMeetingCancellationSlice implements VerticalSlice {
  const RequestMeetingCancellationSlice();

  @override
  String get name => 'request_meeting_cancellation';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final service = RequestMeetingCancellationService(eventStore: services.eventStore);
    registrar
      ..page(
        confirmCancellationRoute,
        title: 'Cancel meeting',
        builder: (request) => ConfirmCancellationPage(
          eventStore: services.eventStore,
          viewerId: request.viewer.employeeId,
          meetingId: request.param('meetingId'),
        ),
      )
      ..form(confirmCancellationRoute, (request) => requestMeetingCancellationHandler(service, request));
  }
}
