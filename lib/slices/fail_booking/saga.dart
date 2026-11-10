import 'package:fmodel/fmodel.dart';

import 'failed_calendar_events/state.dart';
import 'fail_booking/command.dart';

/// The processor `calendar_failure_translator`: each listed negative answer yields one `fail_booking` command for its
/// meeting, with the reason that the answer gives.
final calendarFailureTranslatorSaga = saga<FailedCalendarEventState, FailBookingCommand>((item) async* {
  yield FailBookingCommand(meetingId: item.meetingId, failureReason: item.failureReason);
});
