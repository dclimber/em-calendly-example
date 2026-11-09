import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../ui/paths.dart';
import 'handler.dart';
import 'service.dart';

/// The state_change workflow `start_calendar_connection`. Its screen is a button on the calendar page, which a later
/// slice renders. This slice registers only the form route.
final class StartCalendarConnectionSlice implements VerticalSlice {
  const StartCalendarConnectionSlice();

  @override
  String get name => 'start_calendar_connection';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final service = StartCalendarConnectionService(eventStore: services.eventStore);
    registrar.form(connectCalendarAction, (request) => startCalendarConnectionHandler(service, request));
  }
}
