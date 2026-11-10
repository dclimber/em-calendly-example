import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

/// The decider of the `meeting` aggregate for `request_calendar_event_deletion`.
///
/// The model gives the transition `request_calendar_deletion` from `canceling` only, and it leaves the state
/// unchanged. A repeat for the same cancellation is refused here (see [CalendarEventDeletionAlreadyRequestedError]), so
/// the event is emitted once per cancellation.
final requestCalendarEventDeletionDecider =
    Decider<RequestCalendarEventDeletionCommand, RequestCalendarEventDeletionState, MeetingsEvent>(
      initialState: const RequestCalendarEventDeletionState(),
      decide: (command, state) async* {
        if (state.lifecycle != MeetingLifecycleState.canceling) throw const MeetingNotCancelingError();
        if (state.calendarDeletionRequested) throw const CalendarEventDeletionAlreadyRequestedError();
        yield CalendarEventDeletionRequestedEvent(meetingId: command.meetingId);
      },
      evolve: (state, event) => switch (event) {
        MeetingCancellationRequestedEvent() => RequestCalendarEventDeletionState(
          lifecycle: MeetingLifecycleState.canceling,
        ),
        CalendarEventDeletionRequestedEvent() => state.copyWith(calendarDeletionRequested: true),
        MeetingCancellationFailedEvent() => state.copyWith(lifecycle: MeetingLifecycleState.confirmed),
        MeetingCanceledEvent() => state.copyWith(lifecycle: MeetingLifecycleState.canceled),
        _ => state,
      },
    );
