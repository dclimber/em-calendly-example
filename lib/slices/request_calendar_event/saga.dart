import 'package:fmodel/fmodel.dart';

import 'request_calendar_event/command.dart';
import 'reservations_awaiting_calendar_event/state.dart';

/// The processor `calendar_event_requester`: each verified held slot yields one `request_calendar_event` command for
/// its meeting. An item that is not verified yet yields nothing: its booking is not confirmed free.
final calendarEventRequesterSaga = saga<ReservationAwaitingCalendarEventState, RequestCalendarEventCommand>(
  (item) async* {
    if (!item.verified) return;
    yield RequestCalendarEventCommand(meetingId: item.meetingId);
  },
);
