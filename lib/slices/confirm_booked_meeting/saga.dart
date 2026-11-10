import 'package:fmodel/fmodel.dart';

import 'confirm_meeting/command.dart';
import 'created_calendar_events/state.dart';
import 'processor_state.dart';

/// The input of the processor `calendar_created_translator`: the listed item, and the calendar events its meeting
/// already recorded as confirmed.
typedef CalendarCreatedTranslatorInput = ({RecordedCalendarEventsState recorded, CreatedCalendarEventState item});

/// The processor `calendar_created_translator`: each listed calendar event yields one `confirm_meeting` command for its
/// meeting, unless that calendar event id is already recorded.
final calendarCreatedTranslatorSaga = saga<CalendarCreatedTranslatorInput, ConfirmMeetingCommand>((input) async* {
  if (input.recorded.contains(input.item.calendarEventId)) return;
  yield ConfirmMeetingCommand(meetingId: input.item.meetingId, calendarEventId: input.item.calendarEventId);
});
