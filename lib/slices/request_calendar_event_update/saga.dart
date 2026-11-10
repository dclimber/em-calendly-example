import 'package:fmodel/fmodel.dart';

import 'request_calendar_event_update/command.dart';
import 'reschedules_awaiting_calendar_update/state.dart';

/// The processor `calendar_update_requester`: each verified reschedule yields one `request_calendar_event_update`
/// command for its meeting. An item that is not verified yet yields nothing: its new slot is not confirmed free.
final calendarUpdateRequesterSaga = saga<ReschedulesAwaitingCalendarUpdateState, RequestCalendarEventUpdateCommand>(
  (item) async* {
    if (!item.verified) return;
    yield RequestCalendarEventUpdateCommand(meetingId: item.meetingId, newSlotStart: item.newSlotStart);
  },
);
