import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../ui/paths.dart';
import 'handler.dart';
import 'service.dart';
import 'ui/confirm_new_slot_page.dart';

final class RequestMeetingRescheduleSlice implements VerticalSlice {
  const RequestMeetingRescheduleSlice();

  @override
  String get name => 'request_meeting_reschedule';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final service = RequestMeetingRescheduleService(eventStore: services.eventStore);
    registrar
      ..page(
        confirmNewSlotRoute,
        title: 'Confirm your new time',
        builder: (request) => ConfirmNewSlotPage(
          eventStore: services.eventStore,
          viewerId: request.viewer.employeeId,
          meetingId: request.param('meetingId'),
          start: DateTime.tryParse(request.query['start'] ?? '')?.toUtc(),
          end: DateTime.tryParse(request.query['end'] ?? '')?.toUtc(),
        ),
      )
      ..form(confirmNewSlotRoute, (request) => requestMeetingRescheduleHandler(service, services, request));
  }
}
