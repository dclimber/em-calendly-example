import 'package:fmodel/fmodel.dart';

import 'granted_calendar_access/state.dart';
import 'record_calendar_connected/command.dart';

/// The processor `connection_translator`: a calendar access that the calendar system granted connects the host's
/// calendar. It maps the read-model state to one `record_calendar_connected` command.
final connectionTranslatorSaga = saga<GrantedCalendarAccessState, RecordCalendarConnectedCommand>((granted) async* {
  yield RecordCalendarConnectedCommand(hostId: granted.hostId, calendarAccount: granted.calendarAccount);
});
