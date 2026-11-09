import '../../bounded_contexts/host_setup/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../ui/paths.dart';
import 'handler.dart';
import 'service.dart';
import 'ui/edit_booking_limits_page.dart';

/// The state_change workflow `set_booking_limits`: its screen `edit_booking_limits` and its command.
final class SetBookingLimitsSlice implements VerticalSlice {
  const SetBookingLimitsSlice();

  @override
  String get name => 'set_booking_limits';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final service = SetBookingLimitsService(eventStore: services.eventStore);
    registrar
      ..page(
        bookingLimitsRoute,
        title: 'Booking limits',
        builder: (request) => EditBookingLimitsPage(
          eventStore: services.eventStore,
          scheduleId: ScheduleId(request.param('scheduleId')),
          hostId: HostId(request.viewer.employeeId),
        ),
      )
      ..form(bookingLimitsRoute, (request) => setBookingLimitsHandler(service, request));
  }
}
