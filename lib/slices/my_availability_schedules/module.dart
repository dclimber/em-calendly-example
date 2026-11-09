import '../../bounded_contexts/host_setup/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/view_store/materialized_view.dart';
import '../../ui/paths.dart';
import 'repository.dart';
import 'service.dart';
import 'ui/schedules_page.dart';
import 'view.dart';

final class MyAvailabilitySchedulesSlice implements VerticalSlice {
  const MyAvailabilitySchedulesSlice();

  @override
  String get name => 'my_availability_schedules';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final repository = MyAvailabilitySchedulesRepository(services.viewStore);
    final service = MyAvailabilitySchedulesService(repository: repository);

    registrar
      ..subscribe(
        materializedViewSubscription(
          view: availabilitySchedulesView,
          repository: repository,
          eventTypes: const {
            AvailabilityScheduleCreatedEvent,
            WeeklyHoursSetEvent,
            DateExceptionAddedEvent,
            DateExceptionChangedEvent,
            DateExceptionRemovedEvent,
            BookingLimitsSetEvent,
          },
        ),
      )
      ..nav(const NavItem(label: 'Schedules', path: schedulesRoute, order: 20))
      ..page(
        schedulesRoute,
        title: 'Availability schedules',
        builder: (request) => AvailabilitySchedulesPage(
          service: service,
          hostId: HostId(request.viewer.employeeId),
        ),
      );
  }
}
