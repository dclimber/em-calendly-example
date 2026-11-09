import '../slices/record_calendar_connected/module.dart';
import '../slices/calendar_connection_status/module.dart';
import '../slices/record_host_busy_times/module.dart';
import '../slices/record_calendar_connection_failure/module.dart';
import '../slices/register_employee_on_first_sign_in/module.dart';
import '../slices/start_calendar_connection/module.dart';
import 'vertical_slice.dart';

/// Every slice of the model, in board order. Each new slice adds its import and its `module.dart` instance here.
const List<VerticalSlice> verticalSlices = [
  RegisterEmployeeOnFirstSignInSlice(),
  StartCalendarConnectionSlice(),
  RecordCalendarConnectedSlice(),
  RecordCalendarConnectionFailureSlice(),
  CalendarConnectionStatusSlice(),
  RecordHostBusyTimesSlice(),
];
