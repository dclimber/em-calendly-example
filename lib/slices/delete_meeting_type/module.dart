import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../ui/paths.dart';
import 'handler.dart';
import 'service.dart';

/// The state_change workflow `delete_meeting_type`. Its screen `delete_meeting_type_action` is a button that the
/// meeting types page renders, so this slice registers only the form route.
final class DeleteMeetingTypeSlice implements VerticalSlice {
  const DeleteMeetingTypeSlice();

  @override
  String get name => 'delete_meeting_type';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final service = DeleteMeetingTypeService(eventStore: services.eventStore);
    registrar.form(deleteMeetingTypeRoute, (request) => deleteMeetingTypeHandler(service, request));
  }
}
