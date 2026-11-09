import '../../bounded_contexts/host_setup/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../ui/paths.dart';
import 'handler.dart';
import 'service.dart';
import 'ui/change_exception_page.dart';

/// The state_change workflow `change_date_exception`: its screen `change_exception` and its command.
final class ChangeDateExceptionSlice implements VerticalSlice {
  const ChangeDateExceptionSlice();

  @override
  String get name => 'change_date_exception';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final service = ChangeDateExceptionService(eventStore: services.eventStore);
    registrar
      ..page(
        changeDateExceptionRoute,
        title: 'Change a date exception',
        builder: (request) => ChangeExceptionPage(
          eventStore: services.eventStore,
          scheduleId: ScheduleId(request.param('scheduleId')),
          hostId: HostId(request.viewer.employeeId),
          date: request.param('date'),
        ),
      )
      ..form(changeDateExceptionRoute, (request) => changeDateExceptionHandler(service, request));
  }
}
