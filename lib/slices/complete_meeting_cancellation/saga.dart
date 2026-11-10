import 'package:fmodel/fmodel.dart';

import 'complete_cancellation/command.dart';
import 'deleted_calendar_events/state.dart';

/// The processor `calendar_deleted_translator`: each listed calendar event yields one `complete_cancellation` command for
/// its meeting.
final calendarDeletedTranslatorSaga = saga<DeletedCalendarEventState, CompleteCancellationCommand>((item) async* {
  yield CompleteCancellationCommand(meetingId: item.meetingId);
});
