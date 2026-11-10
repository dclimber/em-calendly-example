import 'package:fmodel/fmodel.dart';

import 'failed_calendar_deletions/state.dart';
import 'fail_cancellation/command.dart';

/// The processor `calendar_deletion_failure_translator`: each listed failed deletion yields one `fail_cancellation`
/// command for its meeting, with the reason that the calendar system gave.
final calendarDeletionFailureTranslatorSaga = saga<FailedCalendarDeletionState, FailCancellationCommand>((item) async* {
  yield FailCancellationCommand(meetingId: item.meetingId, failureReason: item.failureReason);
});
