import 'package:fmodel/fmodel.dart';

import 'request_calendar_event_deletion/command.dart';
import 'cancellations_awaiting_calendar_deletion/state.dart';

/// The processor `calendar_deletion_requester`: each open item of `cancellations_awaiting_calendar_deletion` yields one
/// `request_calendar_event_deletion` command for its meeting.
final calendarDeletionRequesterSaga =
    saga<CancellationAwaitingCalendarDeletionState, RequestCalendarEventDeletionCommand>(
      (item) async* {
        yield RequestCalendarEventDeletionCommand(meetingId: item.meetingId);
      },
    );
