import '../bounded_contexts/corporate_calendar/api.dart';
import '../bounded_contexts/corporate_sso/api.dart';
import '../bounded_contexts/employee_directory/api.dart';
import '../bounded_contexts/host_setup/api.dart';
import '../bounded_contexts/meetings/api.dart';
import '../platform/event_store/event_catalog.dart';

/// Every event contract of the model.
EventCatalog buildEventCatalog() => EventCatalog([
  corporateSsoEventContract,
  corporateCalendarEventContract,
  employeeDirectoryEventContract,
  hostSetupEventContract,
  meetingsEventContract,
]);
