import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/host_setup/api.dart';
import '../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

/// Lifecycle states in which a meeting cannot be rescheduled.
const _endedStates = {
  MeetingLifecycleState.canceled,
  MeetingLifecycleState.completed,
  MeetingLifecycleState.bookingFailed,
};

/// Lifecycle states in which another change to the meeting is still running.
const _inChangeStates = {
  MeetingLifecycleState.pendingCalendar,
  MeetingLifecycleState.rescheduling,
  MeetingLifecycleState.canceling,
};

final requestMeetingRescheduleDecider = Decider<RequestMeetingRescheduleCommand, RescheduleState, DomainEvent>(
  initialState: const RescheduleState(),
  decide: (command, state) async* {
    final meetingId = command.meetingId.value;
    final booking = state.bookings[meetingId];
    final requester = command.requestedBy.value;
    if (booking == null || (requester != booking.hostId && requester != booking.bookerId)) {
      throw const NotAParticipantError();
    }

    final lifecycle = state.lifecycles[meetingId];
    if (_endedStates.contains(lifecycle)) throw const MeetingEndedError();
    if (_inChangeStates.contains(lifecycle)) throw const ChangeInProgressError();

    final calendarEventId = state.calendarEventIds[meetingId];
    if (calendarEventId == null) throw StateError('A confirmed meeting has a calendar event.');

    final check = checkSlot(
      rules: state.schedules[command.scheduleId.value]?.toRules() ?? const AvailabilityRules(),
      slot: (start: command.newSlotStart, end: command.newSlotEnd),
      duration: booking.duration,
      now: command.now,
      busy: state.busy,
      held: [
        for (final entry in state.held.entries)
          if (entry.key != meetingId) ...[?entry.value.current, ?entry.value.pending],
      ],
      calendarFailed: state.calendarFailed,
    );
    final RequestMeetingRescheduleError? refusal = switch (check) {
      SlotCheck.available => null,
      SlotCheck.held || SlotCheck.busy => const SlotUnavailableError(),
      SlotCheck.unverified => const CalendarUnverifiedError(),
      SlotCheck.outsideRules => const SlotOutsideRulesError(),
    };
    if (refusal != null) throw refusal;

    yield MeetingRescheduleRequestedEvent(
      meetingId: command.meetingId,
      hostId: command.hostId,
      requestedBy: command.requestedBy,
      newSlotStart: NewSlotStart(command.newSlotStart),
      newSlotEnd: NewSlotEnd(command.newSlotEnd),
      calendarEventId: CalendarEventId(calendarEventId),
      participants: booking.participants,
    );
  },
  evolve: (state, event) => switch (event) {
    AvailabilityScheduleCreatedEvent(:final scheduleId, :final timeZone) => state.copyWith(
      schedules: {
        ...state.schedules,
        scheduleId.value: ScheduleRules(timeZone: timeZone.value),
      },
    ),
    WeeklyHoursSetEvent(:final scheduleId, :final weeklyHours) => _withSchedule(
      state,
      scheduleId.value,
      (schedule) => schedule.copyWith(weeklyHours: [...weeklyHours.items]),
    ),
    DateExceptionAddedEvent(:final scheduleId, :final exceptionDate, :final exceptionHours) => _withSchedule(
      state,
      scheduleId.value,
      (schedule) => schedule.copyWith(
        dateExceptions: {
          ...schedule.dateExceptions,
          _dayKey(exceptionDate.value): [...exceptionHours.items],
        },
      ),
    ),
    DateExceptionChangedEvent(:final scheduleId, :final exceptionDate, :final exceptionHours) => _withSchedule(
      state,
      scheduleId.value,
      (schedule) => schedule.copyWith(
        dateExceptions: {
          ...schedule.dateExceptions,
          _dayKey(exceptionDate.value): [...exceptionHours.items],
        },
      ),
    ),
    DateExceptionRemovedEvent(:final scheduleId, :final exceptionDate) => _withSchedule(
      state,
      scheduleId.value,
      (schedule) =>
          schedule.copyWith(dateExceptions: {...schedule.dateExceptions}..remove(_dayKey(exceptionDate.value))),
    ),
    BookingLimitsSetEvent(
      :final scheduleId,
      :final bookingWindowDays,
      :final minimumNoticeMinutes,
      :final bufferBeforeMinutes,
      :final bufferAfterMinutes,
    ) =>
      _withSchedule(
        state,
        scheduleId.value,
        (schedule) => schedule.copyWith(
          bookingWindowDays: bookingWindowDays.value,
          minimumNoticeMinutes: minimumNoticeMinutes.value,
          bufferBeforeMinutes: bufferBeforeMinutes.value,
          bufferAfterMinutes: bufferAfterMinutes.value,
        ),
      ),
    CalendarConnectedEvent() => state.copyWith(calendarFailed: false),
    CalendarConnectionFailedEvent() => state.copyWith(calendarFailed: true),
    HostBusyTimesRecordedEvent(:final busyIntervals) => state.copyWith(
      busy: [
        for (final interval in busyIntervals.items) (start: interval.busyFrom, end: interval.busyUntil),
      ],
    ),
    MeetingSlotReservedEvent(
      :final meetingId,
      :final hostId,
      :final bookerId,
      :final slotStart,
      :final slotEnd,
      :final participants,
    ) =>
      state.copyWith(
        bookings: {
          ...state.bookings,
          meetingId.value: ReschedulableBooking(
            hostId: hostId.value,
            bookerId: bookerId.value,
            participants: participants,
            duration: slotEnd.value.difference(slotStart.value),
          ),
        },
        lifecycles: {...state.lifecycles, meetingId.value: MeetingLifecycleState.pendingCalendar},
        held: _withHold(state, meetingId.value, (current: (start: slotStart.value, end: slotEnd.value), pending: null)),
      ),
    MeetingConfirmedEvent(:final meetingId, :final calendarEventId) => state.copyWith(
      lifecycles: {...state.lifecycles, meetingId.value: MeetingLifecycleState.confirmed},
      calendarEventIds: {...state.calendarEventIds, meetingId.value: calendarEventId.value},
    ),
    MeetingRescheduleRequestedEvent(:final meetingId, :final newSlotStart, :final newSlotEnd) => state.copyWith(
      lifecycles: {...state.lifecycles, meetingId.value: MeetingLifecycleState.rescheduling},
      held: _withPending(state, meetingId.value, (start: newSlotStart.value, end: newSlotEnd.value)),
    ),
    MeetingRescheduledEvent(:final meetingId) => state.copyWith(
      lifecycles: {...state.lifecycles, meetingId.value: MeetingLifecycleState.confirmed},
      held: _settled(state, meetingId.value),
    ),
    MeetingRescheduleFailedEvent(:final meetingId) => state.copyWith(
      lifecycles: {...state.lifecycles, meetingId.value: MeetingLifecycleState.confirmed},
      held: _withPending(state, meetingId.value, null),
    ),
    MeetingMovedInCalendarEvent(:final meetingId, :final newSlotStart, :final newSlotEnd) => state.copyWith(
      held: _withHold(state, meetingId.value, (
        current: (start: newSlotStart.value, end: newSlotEnd.value),
        pending: null,
      )),
    ),
    MeetingCancellationRequestedEvent(:final meetingId) => state.copyWith(
      lifecycles: {...state.lifecycles, meetingId.value: MeetingLifecycleState.canceling},
    ),
    MeetingCancellationFailedEvent(:final meetingId) => state.copyWith(
      lifecycles: {...state.lifecycles, meetingId.value: MeetingLifecycleState.confirmed},
    ),
    MeetingCanceledEvent(:final meetingId) => state.copyWith(
      lifecycles: {...state.lifecycles, meetingId.value: MeetingLifecycleState.canceled},
      held: _released(state, meetingId.value),
    ),
    MeetingCompletedEvent(:final meetingId) => state.copyWith(
      lifecycles: {...state.lifecycles, meetingId.value: MeetingLifecycleState.completed},
      held: _released(state, meetingId.value),
    ),
    MeetingBookingFailedEvent(:final meetingId) => state.copyWith(
      lifecycles: {...state.lifecycles, meetingId.value: MeetingLifecycleState.bookingFailed},
      held: _released(state, meetingId.value),
    ),
    _ => state,
  },
);

extension on ScheduleRules {
  AvailabilityRules toRules() => AvailabilityRules(
    timeZone: timeZone,
    weeklyHours: weeklyHours,
    dateExceptions: dateExceptions,
    bookingWindowDays: bookingWindowDays,
    minimumNoticeMinutes: minimumNoticeMinutes,
    bufferBeforeMinutes: bufferBeforeMinutes,
    bufferAfterMinutes: bufferAfterMinutes,
  );
}

/// Changes the schedule with [scheduleId]. A schedule that was never created is left absent.
RescheduleState _withSchedule(
  RescheduleState state,
  String scheduleId,
  ScheduleRules Function(ScheduleRules schedule) change,
) {
  final schedule = state.schedules[scheduleId];
  if (schedule == null) return state;
  return state.copyWith(schedules: {...state.schedules, scheduleId: change(schedule)});
}

DateTime _dayKey(DateTime date) => DateTime.utc(date.year, date.month, date.day);

Map<String, HeldSlot> _withHold(RescheduleState state, String meetingId, HeldSlot hold) => {
  ...state.held,
  meetingId: hold,
};

Map<String, HeldSlot> _withPending(RescheduleState state, String meetingId, SlotSpan? pending) {
  final hold = state.held[meetingId];
  if (hold == null && pending == null) return state.held;
  return {...state.held, meetingId: (current: hold?.current, pending: pending)};
}

Map<String, HeldSlot> _settled(RescheduleState state, String meetingId) {
  final hold = state.held[meetingId];
  if (hold?.pending == null) return state.held;
  return {...state.held, meetingId: (current: hold!.pending, pending: null)};
}

/// The meeting no longer holds time.
Map<String, HeldSlot> _released(RescheduleState state, String meetingId) => {...state.held}..remove(meetingId);
