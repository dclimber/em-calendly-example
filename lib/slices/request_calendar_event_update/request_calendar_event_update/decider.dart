import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

/// The decider of the `meeting` aggregate for `request_calendar_event_update`.
///
/// The model gives the transition `request_calendar_update` from `rescheduling` only, and it leaves the state in
/// `rescheduling`. A repeat for the current reschedule request is refused here (see
/// [CalendarEventUpdateAlreadyRequestedError]), so the event is emitted once per reschedule request.
final requestCalendarEventUpdateDecider =
    Decider<RequestCalendarEventUpdateCommand, RequestCalendarEventUpdateState, MeetingsEvent>(
      initialState: const RequestCalendarEventUpdateState(),
      decide: (command, state) async* {
        if (state.lifecycle != MeetingLifecycleState.rescheduling) throw const MeetingNotReschedulingError();
        if (state.calendarEventUpdateRequested) throw const CalendarEventUpdateAlreadyRequestedError();
        yield CalendarEventUpdateRequestedEvent(meetingId: command.meetingId, newSlotStart: command.newSlotStart);
      },
      evolve: (state, event) => switch (event) {
        MeetingSlotReservedEvent() => RequestCalendarEventUpdateState(
          lifecycle: MeetingLifecycleState.pendingCalendar,
          calendarEventUpdateRequested: state.calendarEventUpdateRequested,
        ),
        MeetingConfirmedEvent() ||
        MeetingRescheduledEvent() ||
        MeetingRescheduleFailedEvent() ||
        MeetingMovedInCalendarEvent() => RequestCalendarEventUpdateState(
          lifecycle: MeetingLifecycleState.confirmed,
          calendarEventUpdateRequested: state.calendarEventUpdateRequested,
        ),
        MeetingBookingFailedEvent() => RequestCalendarEventUpdateState(
          lifecycle: MeetingLifecycleState.bookingFailed,
          calendarEventUpdateRequested: state.calendarEventUpdateRequested,
        ),
        MeetingRescheduleRequestedEvent() => const RequestCalendarEventUpdateState(
          lifecycle: MeetingLifecycleState.rescheduling,
        ),
        CalendarEventUpdateRequestedEvent() => RequestCalendarEventUpdateState(
          lifecycle: state.lifecycle,
          calendarEventUpdateRequested: true,
        ),
        MeetingCancellationRequestedEvent() => RequestCalendarEventUpdateState(
          lifecycle: MeetingLifecycleState.canceling,
          calendarEventUpdateRequested: state.calendarEventUpdateRequested,
        ),
        MeetingCanceledEvent() => RequestCalendarEventUpdateState(
          lifecycle: MeetingLifecycleState.canceled,
          calendarEventUpdateRequested: state.calendarEventUpdateRequested,
        ),
        MeetingCompletedEvent() => RequestCalendarEventUpdateState(
          lifecycle: MeetingLifecycleState.completed,
          calendarEventUpdateRequested: state.calendarEventUpdateRequested,
        ),
        _ => state,
      },
    );
