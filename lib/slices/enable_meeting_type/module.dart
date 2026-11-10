import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../ui/paths.dart';
import 'handler.dart';
import 'service.dart';

/// The state_change workflow `enable_meeting_type`. Its screen `enable_meeting_type_action` is a button that the
/// meeting types page renders, so this slice registers only the form route.
final class EnableMeetingTypeSlice implements VerticalSlice {
  const EnableMeetingTypeSlice();

  @override
  String get name => 'enable_meeting_type';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final service = EnableMeetingTypeService(eventStore: services.eventStore);
    registrar.form(enableMeetingTypeRoute, (request) => enableMeetingTypeHandler(service, request));
  }
}
