import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../ui/paths.dart';
import 'handler.dart';
import 'service.dart';

/// The state_change workflow `disable_meeting_type`. Its screen `disable_meeting_type_action` is a button that the
/// meeting types page renders, so this slice registers only the form route.
final class DisableMeetingTypeSlice implements VerticalSlice {
  const DisableMeetingTypeSlice();

  @override
  String get name => 'disable_meeting_type';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final service = DisableMeetingTypeService(eventStore: services.eventStore);
    registrar.form(disableMeetingTypeRoute, (request) => disableMeetingTypeHandler(service, request));
  }
}
