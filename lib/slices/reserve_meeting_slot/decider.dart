import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/employee_directory/api.dart';
import '../../bounded_contexts/host_setup/api.dart';
import '../../bounded_contexts/meetings/api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

/// The decider of `reserve_meeting_slot`. It yields only `meeting_slot_reserved`. Refusals are the sealed
/// [ReserveMeetingSlotError]s, with the texts of the model.
final reserveMeetingSlotDecider = Decider<ReserveMeetingSlotCommand, ReserveMeetingSlotState, DomainEvent>(
  initialState: const ReserveMeetingSlotState(),
  decide: (command, state) async* {
    final type = state.meetingType;
    if (type == null || !type.accepting || type.deleted) throw const MeetingTypeNotAcceptingError();
    if (command.bookerId.value == type.hostId) throw const SelfBookingError();

    final check = checkSlot(
      rules: state.schedule?.toRules() ?? const AvailabilityRules(),
      slot: (start: command.slotStart, end: command.slotEnd),
      duration: Duration(minutes: type.durationMinutes),
      now: command.now,
      busy: state.busy,
      held: [
        for (final h in state.held.values) ...[?h.current, ?h.pending],
      ],
      calendarFailed: state.calendarFailed,
    );
    final error = switch (check) {
      SlotCheck.held => const SlotHeldError(),
      SlotCheck.unverified => const CalendarUnverifiedError(),
      SlotCheck.busy => const SlotBusyError(),
      SlotCheck.outsideRules => const SlotOutsideRulesError(),
      SlotCheck.available => null,
    };
    if (error != null) throw error;

    yield MeetingSlotReservedEvent(
      meetingId: command.meetingId,
      hostId: command.hostId,
      bookerId: command.bookerId,
      meetingTypeId: command.meetingTypeId,
      meetingTitle: MeetingTitle(type.title),
      meetingLocation: MeetingLocation(type.location),
      slotStart: SlotStart(command.slotStart),
      slotEnd: SlotEnd(command.slotEnd),
      participants: Participants([
        Participant(
          employeeId: EmployeeId(type.hostId),
          name: EmployeeName(state.hostName ?? type.hostId),
          email: EmployeeEmail(state.hostEmail ?? ''),
          role: 'host',
        ),
        Participant(
          employeeId: EmployeeId(command.bookerId.value),
          name: command.bookerName,
          email: command.bookerEmail,
          role: 'booker',
        ),
      ]),
    );
  },
  evolve: (state, event) => switch (event) {
    MeetingTypeCreatedEvent(
      :final hostId,
      :final meetingTitle,
      :final durationMinutes,
      :final meetingLocation,
      :final scheduleId,
    ) =>
      state.copyWith(
        meetingType: BookableMeetingType(
          hostId: hostId.value,
          scheduleId: scheduleId.value,
          title: meetingTitle.value,
          location: meetingLocation.value,
          durationMinutes: durationMinutes.value,
          accepting: true,
          deleted: false,
        ),
      ),
    MeetingTypeEditedEvent(:final meetingTitle, :final durationMinutes, :final meetingLocation, :final scheduleId) =>
      state.copyWith(
        meetingType: state.meetingType?.copyWith(
          scheduleId: scheduleId.value,
          title: meetingTitle.value,
          location: meetingLocation.value,
          durationMinutes: durationMinutes.value,
        ),
      ),
    MeetingTypeDisabledEvent() => state.copyWith(meetingType: state.meetingType?.copyWith(accepting: false)),
    MeetingTypeEnabledEvent() => state.copyWith(
      meetingType: state.meetingType?.copyWith(accepting: !(state.meetingType?.deleted ?? true)),
    ),
    MeetingTypeDeletedEvent() => state.copyWith(
      meetingType: state.meetingType?.copyWith(accepting: false, deleted: true),
    ),
    AvailabilityScheduleCreatedEvent(:final timeZone) => state.copyWith(
      schedule: ScheduleRules(timeZone: timeZone.value),
    ),
    WeeklyHoursSetEvent(:final weeklyHours) => state.copyWith(
      schedule: state.schedule?.copyWith(weeklyHours: [...weeklyHours.items]),
    ),
    DateExceptionAddedEvent(:final exceptionDate, :final exceptionHours) => _withException(
      state,
      exceptionDate.value,
      [...exceptionHours.items],
    ),
    DateExceptionChangedEvent(:final exceptionDate, :final exceptionHours) => _withException(
      state,
      exceptionDate.value,
      [...exceptionHours.items],
    ),
    DateExceptionRemovedEvent(:final exceptionDate) => _withoutException(state, exceptionDate.value),
    BookingLimitsSetEvent(
      :final bookingWindowDays,
      :final minimumNoticeMinutes,
      :final bufferBeforeMinutes,
      :final bufferAfterMinutes,
    ) =>
      state.copyWith(
        schedule: state.schedule?.copyWith(
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
    EmployeeRegisteredEvent(:final employeeName, :final employeeEmail) => state.copyWith(
      hostName: employeeName.value,
      hostEmail: employeeEmail.value,
    ),
    MeetingSlotReservedEvent(:final meetingId, :final slotStart, :final slotEnd) => _withHold(
      state,
      meetingId.value,
      (current: (start: slotStart.value, end: slotEnd.value), pending: null),
    ),
    MeetingRescheduleRequestedEvent(:final meetingId, :final newSlotStart, :final newSlotEnd) => _withPending(
      state,
      meetingId.value,
      (start: newSlotStart.value, end: newSlotEnd.value),
    ),
    MeetingRescheduleFailedEvent(:final meetingId) => _withPending(state, meetingId.value, null),
    MeetingRescheduledEvent(:final meetingId) => _settled(state, meetingId.value),
    MeetingMovedInCalendarEvent(:final meetingId, :final newSlotStart, :final newSlotEnd) => _withHold(
      state,
      meetingId.value,
      (current: (start: newSlotStart.value, end: newSlotEnd.value), pending: null),
    ),
    MeetingBookingFailedEvent(:final meetingId) => _released(state, meetingId.value),
    MeetingCanceledEvent(:final meetingId) => _released(state, meetingId.value),
    MeetingCompletedEvent(:final meetingId) => _released(state, meetingId.value),
    _ => state,
  },
);

ReserveMeetingSlotState _withException(ReserveMeetingSlotState state, DateTime date, List<ExceptionHoursRange> hours) {
  final schedule = state.schedule;
  if (schedule == null) return state;
  return state.copyWith(
    schedule: schedule.copyWith(dateExceptions: {...schedule.dateExceptions, _dayKey(date): hours}),
  );
}

ReserveMeetingSlotState _withoutException(ReserveMeetingSlotState state, DateTime date) {
  final schedule = state.schedule;
  if (schedule == null) return state;
  return state.copyWith(
    schedule: schedule.copyWith(dateExceptions: {...schedule.dateExceptions}..remove(_dayKey(date))),
  );
}

ReserveMeetingSlotState _withHold(ReserveMeetingSlotState state, String meetingId, HeldSlot hold) =>
    state.copyWith(held: {...state.held, meetingId: hold});

/// Sets the pending slot of [meetingId] to [pending] (null clears it). A pending slot holds time even before the
/// meeting holds a current slot.
ReserveMeetingSlotState _withPending(
  ReserveMeetingSlotState state,
  String meetingId,
  ({DateTime start, DateTime end})? pending,
) {
  final hold = state.held[meetingId];
  if (hold == null && pending == null) return state;
  return _withHold(state, meetingId, (current: hold?.current, pending: pending));
}

/// A reschedule was completed: the pending slot becomes the current slot.
ReserveMeetingSlotState _settled(ReserveMeetingSlotState state, String meetingId) {
  final hold = state.held[meetingId];
  if (hold?.pending == null) return state;
  return _withHold(state, meetingId, (current: hold!.pending, pending: null));
}

/// The meeting no longer holds time.
ReserveMeetingSlotState _released(ReserveMeetingSlotState state, String meetingId) =>
    state.copyWith(held: {...state.held}..remove(meetingId));

DateTime _dayKey(DateTime date) => DateTime.utc(date.year, date.month, date.day);

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
