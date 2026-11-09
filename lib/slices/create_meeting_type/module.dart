import '../../bounded_contexts/host_setup/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../ui/paths.dart';
import 'handler.dart';
import 'service.dart';
import 'ui/new_meeting_type_page.dart';

final class CreateMeetingTypeSlice implements VerticalSlice {
  const CreateMeetingTypeSlice();

  @override
  String get name => 'create_meeting_type';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final service = CreateMeetingTypeService(eventStore: services.eventStore);

    registrar
      ..page(
        newMeetingTypeRoute,
        title: 'New meeting type',
        builder: (request) => NewMeetingTypePage(
          eventStore: services.eventStore,
          hostId: HostId(request.viewer.employeeId),
        ),
      )
      ..form(meetingTypesRoute, (request) => createMeetingTypeHandler(service, services, request));
  }
}
