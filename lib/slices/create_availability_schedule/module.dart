import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../ui/paths.dart';
import 'handler.dart';
import 'service.dart';
import 'ui/new_availability_schedule_page.dart';

/// The state_change workflow `create_availability_schedule`: its screen `new_availability_schedule` and its command.
final class CreateAvailabilityScheduleSlice implements VerticalSlice {
  const CreateAvailabilityScheduleSlice();

  @override
  String get name => 'create_availability_schedule';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final service = CreateAvailabilityScheduleService(eventStore: services.eventStore);
    registrar
      ..page(
        newScheduleRoute,
        title: 'New availability schedule',
        builder: (request) => const NewAvailabilitySchedulePage(),
      )
      ..form(
        schedulesRoute,
        (request) => createAvailabilityScheduleHandler(service, services.ids, request),
      );
  }
}
