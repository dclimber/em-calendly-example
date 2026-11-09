import '../../bounded_contexts/host_setup/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../ui/paths.dart';
import 'handler.dart';
import 'service.dart';
import 'ui/edit_weekly_hours_page.dart';

/// The state_change workflow `set_weekly_hours`: its screen `edit_weekly_hours` and its command.
final class SetWeeklyHoursSlice implements VerticalSlice {
  const SetWeeklyHoursSlice();

  @override
  String get name => 'set_weekly_hours';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final service = SetWeeklyHoursService(eventStore: services.eventStore);
    registrar
      ..page(
        weeklyHoursRoute,
        title: 'Weekly hours',
        builder: (request) => EditWeeklyHoursPage(
          eventStore: services.eventStore,
          scheduleId: ScheduleId(request.param('scheduleId')),
          hostId: HostId(request.viewer.employeeId),
        ),
      )
      ..form(weeklyHoursRoute, (request) => setWeeklyHoursHandler(service, request));
  }
}
