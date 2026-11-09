import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../ui/paths.dart';
import 'handler.dart';
import 'service.dart';

/// The state_change workflow `remove_date_exception`. Its screen `remove_exception` is a button that the schedules
/// page renders, so this slice registers only the form route.
final class RemoveDateExceptionSlice implements VerticalSlice {
  const RemoveDateExceptionSlice();

  @override
  String get name => 'remove_date_exception';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final service = RemoveDateExceptionService(eventStore: services.eventStore);
    registrar.form(removeDateExceptionRoute, (request) => removeDateExceptionHandler(service, request));
  }
}
