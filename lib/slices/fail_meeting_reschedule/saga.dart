import 'package:fmodel/fmodel.dart';

import 'failed_calendar_updates/state.dart';
import 'fail_reschedule/command.dart';

/// The processor `calendar_update_failure_translator`: each listed negative answer yields one `fail_reschedule` command
/// for its meeting, with the reason that the answer gives.
final calendarUpdateFailureTranslatorSaga = saga<FailedCalendarUpdateState, FailRescheduleCommand>((item) async* {
  yield FailRescheduleCommand(meetingId: item.meetingId, failureReason: item.failureReason);
});
