import '../../bounded_contexts/host_setup/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/view_store/materialized_view.dart';
import '../../ui/paths.dart';
import 'repository.dart';
import 'service.dart';
import 'ui/meeting_types_page.dart';
import 'view.dart';

final class MyMeetingTypesSlice implements VerticalSlice {
  const MyMeetingTypesSlice();

  @override
  String get name => 'my_meeting_types';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final repository = MyMeetingTypesRepository(services.viewStore);
    final service = MyMeetingTypesService(repository: repository);

    registrar
      ..subscribe(
        materializedViewSubscription(
          view: myMeetingTypesView,
          repository: repository,
          eventTypes: const {
            MeetingTypeCreatedEvent,
            MeetingTypeEditedEvent,
            MeetingTypeDisabledEvent,
            MeetingTypeEnabledEvent,
            MeetingTypeDeletedEvent,
          },
        ),
      )
      ..nav(const NavItem(label: 'Meeting types', path: meetingTypesRoute, order: 30))
      ..page(
        meetingTypesRoute,
        title: 'Meeting types',
        builder: (request) => MeetingTypesPage(
          service: service,
          hostId: HostId(request.viewer.employeeId),
        ),
      );
  }
}
