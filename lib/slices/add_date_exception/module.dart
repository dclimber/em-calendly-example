import '../../bounded_contexts/host_setup/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../ui/paths.dart';
import 'handler.dart';
import 'service.dart';
import 'ui/add_exception_page.dart';

/// The state_change workflow `add_date_exception`: its screen `add_exception` and its command.
final class AddDateExceptionSlice implements VerticalSlice {
  const AddDateExceptionSlice();

  @override
  String get name => 'add_date_exception';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final service = AddDateExceptionService(eventStore: services.eventStore);
    registrar
      ..page(
        newDateExceptionRoute,
        title: 'Add a date exception',
        builder: (request) => AddExceptionPage(
          eventStore: services.eventStore,
          scheduleId: ScheduleId(request.param('scheduleId')),
          hostId: HostId(request.viewer.employeeId),
        ),
      )
      ..form(dateExceptionsActionRoute, (request) => addDateExceptionHandler(service, request));
  }
}
