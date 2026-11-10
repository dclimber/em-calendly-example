import 'package:fmodel/fmodel.dart';

import 'complete_reschedule/command.dart';
import 'updated_calendar_events/state.dart';

/// The processor `calendar_updated_translator`: each listed calendar event yields one `complete_reschedule` command for
/// its meeting.
final calendarUpdatedTranslatorSaga = saga<UpdatedCalendarEventState, CompleteRescheduleCommand>((item) async* {
  yield CompleteRescheduleCommand(meetingId: item.meetingId);
});
