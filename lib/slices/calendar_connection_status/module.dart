import '../../bounded_contexts/host_setup/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/view_store/materialized_view.dart';
import '../../ui/paths.dart';
import 'repository.dart';
import 'service.dart';
import 'ui/calendar_connection_page.dart';
import 'view.dart';

/// The state_view workflow `view_calendar_connection`: the read model `calendar_connection_status` and its screen.
final class CalendarConnectionStatusSlice implements VerticalSlice {
  const CalendarConnectionStatusSlice();

  @override
  String get name => 'calendar_connection_status';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final repository = CalendarConnectionStatusRepository(services.viewStore);
    final service = CalendarConnectionStatusService(repository: repository);
    registrar
      ..subscribe(
        materializedViewSubscription(
          view: calendarConnectionStatusView,
          repository: repository,
          eventTypes: {CalendarConnectionStartedEvent, CalendarConnectedEvent, CalendarConnectionFailedEvent},
        ),
      )
      ..nav(const NavItem(label: 'Calendar', path: calendarRoute, order: 10))
      ..page(
        calendarRoute,
        title: 'Calendar connection',
        builder: (request) => CalendarConnectionPage(
          service: service,
          hostId: HostId(request.viewer.employeeId),
        ),
      );
  }
}
