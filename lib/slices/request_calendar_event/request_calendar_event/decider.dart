import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

/// The decider of the `meeting` aggregate for `request_calendar_event`.
///
/// The model gives the transition `request_calendar_event` from `pending_calendar` only, and it leaves the state
/// unchanged. A repeat is refused here (see [CalendarEventAlreadyRequestedError]), so the event is emitted once.
final requestCalendarEventDecider = Decider<RequestCalendarEventCommand, RequestCalendarEventState, MeetingsEvent>(
  initialState: const RequestCalendarEventState(),
  decide: (command, state) async* {
    if (state.lifecycle != MeetingLifecycleState.pendingCalendar) {
      throw const MeetingNotPendingCalendarError();
    }
    if (state.calendarEventRequested) throw const CalendarEventAlreadyRequestedError();
    yield CalendarEventRequestedEvent(meetingId: command.meetingId);
  },
  evolve: (state, event) => switch (event) {
    MeetingSlotReservedEvent() => RequestCalendarEventState(
      lifecycle: MeetingLifecycleState.pendingCalendar,
      calendarEventRequested: state.calendarEventRequested,
    ),
    CalendarEventRequestedEvent() => RequestCalendarEventState(
      lifecycle: state.lifecycle,
      calendarEventRequested: true,
    ),
    MeetingConfirmedEvent() => RequestCalendarEventState(
      lifecycle: MeetingLifecycleState.confirmed,
      calendarEventRequested: state.calendarEventRequested,
    ),
    MeetingBookingFailedEvent() => RequestCalendarEventState(
      lifecycle: MeetingLifecycleState.bookingFailed,
      calendarEventRequested: state.calendarEventRequested,
    ),
    _ => state,
  },
);
