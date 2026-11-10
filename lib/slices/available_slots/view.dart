import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/employee_directory/api.dart';
import '../../bounded_contexts/host_setup/api.dart';
import '../../bounded_contexts/meetings/api.dart';
import 'state.dart';

/// The read model `available_slots` (`view_available_slots` in the model). A host document is created by the first
/// event that names its host. Events about a schedule, meeting type, or meeting change the document only when it
/// exists, which holds because each of those streams starts with an event that names the host.
final availableSlotsView = View<AvailableSlotsState?, DomainEvent>(
  initialState: null,
  evolve: (state, event) => switch (event) {
    EmployeeRegisteredEvent(:final employeeId, :final employeeName) =>
      (state ?? AvailableSlotsState.empty(employeeId.value)).copyWith(hostName: employeeName.value),
    CalendarConnectedEvent(:final hostId) => _host(state, hostId.value).copyWith(calendarFailed: false),
    CalendarConnectionFailedEvent(:final hostId) => _host(state, hostId.value).copyWith(calendarFailed: true),
    HostBusyTimesRecordedEvent(:final hostId, :final busyIntervals) => _host(state, hostId.value).copyWith(
      busy: [
        for (final interval in busyIntervals.items) (start: interval.busyFrom, end: interval.busyUntil),
      ],
    ),
    AvailabilityScheduleCreatedEvent(:final scheduleId, :final hostId, :final timeZone) => _host(
      state,
      hostId.value,
    ).withSchedule(scheduleId.value, ScheduleState(timeZone: timeZone.value)),
    WeeklyHoursSetEvent(:final scheduleId, :final weeklyHours) => state?.updateSchedule(
      scheduleId.value,
      (s) => s.withWeeklyHours([...weeklyHours.items]),
    ),
    DateExceptionAddedEvent(:final scheduleId, :final exceptionDate, :final exceptionHours) => state?.updateSchedule(
      scheduleId.value,
      (s) => s.withDateException(dateKey(exceptionDate.value), [...exceptionHours.items]),
    ),
    DateExceptionChangedEvent(:final scheduleId, :final exceptionDate, :final exceptionHours) => state?.updateSchedule(
      scheduleId.value,
      (s) => s.withDateException(dateKey(exceptionDate.value), [...exceptionHours.items]),
    ),
    DateExceptionRemovedEvent(:final scheduleId, :final exceptionDate) => state?.updateSchedule(
      scheduleId.value,
      (s) => s.withoutDateException(dateKey(exceptionDate.value)),
    ),
    BookingLimitsSetEvent(
      :final scheduleId,
      :final bookingWindowDays,
      :final minimumNoticeMinutes,
      :final bufferBeforeMinutes,
      :final bufferAfterMinutes,
    ) =>
      state?.updateSchedule(
        scheduleId.value,
        (s) => s.withLimits(
          bookingWindowDays: bookingWindowDays.value,
          minimumNoticeMinutes: minimumNoticeMinutes.value,
          bufferBeforeMinutes: bufferBeforeMinutes.value,
          bufferAfterMinutes: bufferAfterMinutes.value,
        ),
      ),
    MeetingTypeCreatedEvent(
      :final meetingTypeId,
      :final hostId,
      :final meetingTitle,
      :final durationMinutes,
      :final meetingLocation,
      :final scheduleId,
      :final meetingDescription,
    ) =>
      _host(state, hostId.value).withMeetingType(
        meetingTypeId.value,
        MeetingTypeState(
          scheduleId: scheduleId.value,
          title: meetingTitle.value,
          durationMinutes: durationMinutes.value,
          location: meetingLocation.value,
          description: meetingDescription?.value,
          accepting: true,
        ),
      ),
    MeetingTypeEditedEvent(
      :final meetingTypeId,
      :final meetingTitle,
      :final durationMinutes,
      :final meetingLocation,
      :final scheduleId,
      :final meetingDescription,
    ) =>
      state?.updateMeetingType(
        meetingTypeId.value,
        (t) => t.withDetails(
          scheduleId: scheduleId.value,
          title: meetingTitle.value,
          durationMinutes: durationMinutes.value,
          location: meetingLocation.value,
          description: meetingDescription?.value,
        ),
      ),
    MeetingTypeDisabledEvent(:final meetingTypeId) => state?.updateMeetingType(
      meetingTypeId.value,
      (t) => t.withAccepting(false),
    ),
    MeetingTypeEnabledEvent(:final meetingTypeId) => state?.updateMeetingType(
      meetingTypeId.value,
      (t) => t.withAccepting(true),
    ),
    MeetingTypeDeletedEvent(:final meetingTypeId) => state?.updateMeetingType(
      meetingTypeId.value,
      (t) => t.withAccepting(false),
    ),
    MeetingSlotReservedEvent(
      :final meetingId,
      :final hostId,
      :final bookerId,
      :final meetingTypeId,
      :final slotStart,
      :final slotEnd,
    ) =>
      _host(state, hostId.value).withMeeting(
        meetingId.value,
        HeldMeeting(
          meetingTypeId: meetingTypeId.value,
          bookerId: bookerId.value,
          current: (start: slotStart.value, end: slotEnd.value),
        ),
      ),
    MeetingBookingFailedEvent(:final meetingId) => state?.withoutMeeting(meetingId.value),
    MeetingCanceledEvent(:final meetingId) => state?.withoutMeeting(meetingId.value),
    MeetingRescheduleRequestedEvent(:final meetingId, :final newSlotStart, :final newSlotEnd) => state?.updateMeeting(
      meetingId.value,
      (m) => m.withPending((start: newSlotStart.value, end: newSlotEnd.value)),
    ),
    MeetingRescheduledEvent(:final meetingId) => state?.updateMeeting(meetingId.value, (m) => m.settled()),
    MeetingMovedInCalendarEvent(:final meetingId, :final newSlotStart, :final newSlotEnd) => state?.updateMeeting(
      meetingId.value,
      (m) => m.movedTo((start: newSlotStart.value, end: newSlotEnd.value)),
    ),
    MeetingRescheduleFailedEvent(:final meetingId) => state?.updateMeeting(
      meetingId.value,
      (m) => m.withPending(null),
    ),
    _ => state,
  },
);

AvailableSlotsState _host(AvailableSlotsState? state, String hostId) => state ?? AvailableSlotsState.empty(hostId);

extension on AvailableSlotsState {
  AvailableSlotsState withSchedule(String scheduleId, ScheduleState schedule) =>
      copyWith(schedules: {...schedules, scheduleId: schedule});

  AvailableSlotsState updateSchedule(String scheduleId, ScheduleState Function(ScheduleState) change) {
    final schedule = schedules[scheduleId];
    if (schedule == null) return this;
    return copyWith(schedules: {...schedules, scheduleId: change(schedule)});
  }

  AvailableSlotsState withMeetingType(String meetingTypeId, MeetingTypeState meetingType) =>
      copyWith(meetingTypes: {...meetingTypes, meetingTypeId: meetingType});

  AvailableSlotsState updateMeetingType(String meetingTypeId, MeetingTypeState Function(MeetingTypeState) change) {
    final meetingType = meetingTypes[meetingTypeId];
    if (meetingType == null) return this;
    return copyWith(meetingTypes: {...meetingTypes, meetingTypeId: change(meetingType)});
  }

  AvailableSlotsState withMeeting(String meetingId, HeldMeeting meeting) =>
      copyWith(meetings: {...meetings, meetingId: meeting});

  AvailableSlotsState updateMeeting(String meetingId, HeldMeeting Function(HeldMeeting) change) {
    final meeting = meetings[meetingId];
    if (meeting == null) return this;
    return copyWith(meetings: {...meetings, meetingId: change(meeting)});
  }

  AvailableSlotsState withoutMeeting(String meetingId) => copyWith(meetings: {...meetings}..remove(meetingId));
}
