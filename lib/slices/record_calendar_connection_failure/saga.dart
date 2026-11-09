import 'package:fmodel/fmodel.dart';

import 'failed_calendar_access/state.dart';
import 'record_connection_failure/command.dart';

/// The processor `connection_failure_translator`: a calendar access failure that the calendar system reported records
/// the host's calendar connection as failed. It maps the read-model state to one `record_connection_failure` command.
final connectionFailureTranslatorSaga = saga<FailedCalendarAccessState, RecordConnectionFailureCommand>((
  failed,
) async* {
  yield RecordConnectionFailureCommand(hostId: failed.hostId, connectionFailure: failed.connectionFailure);
});
