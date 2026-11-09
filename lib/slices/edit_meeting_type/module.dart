import '../../bounded_contexts/host_setup/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../ui/paths.dart';
import 'handler.dart';
import 'service.dart';
import 'ui/edit_meeting_type_page.dart';

/// The state_change workflow `edit_meeting_type`: its screen `edit_meeting_type_form` and its command.
final class EditMeetingTypeSlice implements VerticalSlice {
  const EditMeetingTypeSlice();

  @override
  String get name => 'edit_meeting_type';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final service = EditMeetingTypeService(eventStore: services.eventStore);
    registrar
      ..page(
        editMeetingTypeRoute,
        title: 'Edit meeting type',
        builder: (request) => EditMeetingTypePage(
          eventStore: services.eventStore,
          meetingTypeId: MeetingTypeId(request.param('meetingTypeId')),
          hostId: HostId(request.viewer.employeeId),
        ),
      )
      ..form(editMeetingTypeRoute, (request) => editMeetingTypeHandler(service, request));
  }
}
