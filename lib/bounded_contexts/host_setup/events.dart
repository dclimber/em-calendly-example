/// Events of the `host_setup` bounded context.
library;

import '../event_contract.dart';
import 'value_objects.dart';

/// An event of the `host_setup` bounded context.
///
/// What a host configures: the calendar connection, availability rules, and meeting types.
sealed class HostSetupEvent implements DomainEvent {
  const HostSetupEvent();
}

/// The `calendar_connection_started` event.
///
/// Aggregate: `calendar_connection`.
final class CalendarConnectionStartedEvent extends HostSetupEvent {
  const CalendarConnectionStartedEvent({required this.hostId});

  final HostId hostId;

  @override
  bool operator ==(Object other) => other is CalendarConnectionStartedEvent && other.hostId == hostId;

  @override
  int get hashCode => Object.hash(runtimeType, hostId);

  @override
  String toString() => 'CalendarConnectionStartedEvent(hostId: $hostId)';
}

/// The `calendar_connected` event.
///
/// Aggregate: `calendar_connection`.
final class CalendarConnectedEvent extends HostSetupEvent {
  const CalendarConnectedEvent({required this.hostId, required this.calendarAccount});

  final HostId hostId;
  final CalendarAccount calendarAccount;

  @override
  bool operator ==(Object other) =>
      other is CalendarConnectedEvent && other.hostId == hostId && other.calendarAccount == calendarAccount;

  @override
  int get hashCode => Object.hash(runtimeType, hostId, calendarAccount);

  @override
  String toString() => 'CalendarConnectedEvent(hostId: $hostId, calendarAccount: $calendarAccount)';
}

/// The `calendar_connection_failed` event.
///
/// Aggregate: `calendar_connection`.
final class CalendarConnectionFailedEvent extends HostSetupEvent {
  const CalendarConnectionFailedEvent({required this.hostId, required this.connectionFailure});

  final HostId hostId;
  final ConnectionFailure connectionFailure;

  @override
  bool operator ==(Object other) =>
      other is CalendarConnectionFailedEvent && other.hostId == hostId && other.connectionFailure == connectionFailure;

  @override
  int get hashCode => Object.hash(runtimeType, hostId, connectionFailure);

  @override
  String toString() => 'CalendarConnectionFailedEvent(hostId: $hostId, connectionFailure: $connectionFailure)';
}

/// Holds free/busy intervals only. Event titles, attendees, and contents never enter the scheduler.
///
/// Aggregate: `calendar_connection`.
final class HostBusyTimesRecordedEvent extends HostSetupEvent {
  const HostBusyTimesRecordedEvent({required this.hostId, required this.busyIntervals});

  final HostId hostId;
  final BusyIntervals busyIntervals;

  @override
  bool operator ==(Object other) =>
      other is HostBusyTimesRecordedEvent && other.hostId == hostId && other.busyIntervals == busyIntervals;

  @override
  int get hashCode => Object.hash(runtimeType, hostId, busyIntervals);

  @override
  String toString() => 'HostBusyTimesRecordedEvent(hostId: $hostId, busyIntervals: $busyIntervals)';
}

/// The `availability_schedule_created` event.
///
/// Aggregate: `availability_schedule`.
final class AvailabilityScheduleCreatedEvent extends HostSetupEvent {
  const AvailabilityScheduleCreatedEvent({
    required this.scheduleId,
    required this.hostId,
    required this.scheduleName,
    required this.timeZone,
  });

  final ScheduleId scheduleId;
  final HostId hostId;
  final ScheduleName scheduleName;
  final TimeZone timeZone;

  @override
  bool operator ==(Object other) =>
      other is AvailabilityScheduleCreatedEvent &&
      other.scheduleId == scheduleId &&
      other.hostId == hostId &&
      other.scheduleName == scheduleName &&
      other.timeZone == timeZone;

  @override
  int get hashCode => Object.hash(runtimeType, scheduleId, hostId, scheduleName, timeZone);

  @override
  String toString() =>
      'AvailabilityScheduleCreatedEvent(scheduleId: $scheduleId, hostId: $hostId, scheduleName: $scheduleName, timeZone: $timeZone)';
}

/// The `weekly_hours_set` event.
///
/// Aggregate: `availability_schedule`.
final class WeeklyHoursSetEvent extends HostSetupEvent {
  const WeeklyHoursSetEvent({required this.scheduleId, required this.weeklyHours});

  final ScheduleId scheduleId;
  final WeeklyHours weeklyHours;

  @override
  bool operator ==(Object other) =>
      other is WeeklyHoursSetEvent && other.scheduleId == scheduleId && other.weeklyHours == weeklyHours;

  @override
  int get hashCode => Object.hash(runtimeType, scheduleId, weeklyHours);

  @override
  String toString() => 'WeeklyHoursSetEvent(scheduleId: $scheduleId, weeklyHours: $weeklyHours)';
}

/// Empty exception_hours mean that the whole date is unavailable.
///
/// Aggregate: `availability_schedule`.
final class DateExceptionAddedEvent extends HostSetupEvent {
  const DateExceptionAddedEvent({required this.scheduleId, required this.exceptionDate, required this.exceptionHours});

  final ScheduleId scheduleId;
  final ExceptionDate exceptionDate;
  final ExceptionHours exceptionHours;

  @override
  bool operator ==(Object other) =>
      other is DateExceptionAddedEvent &&
      other.scheduleId == scheduleId &&
      other.exceptionDate == exceptionDate &&
      other.exceptionHours == exceptionHours;

  @override
  int get hashCode => Object.hash(runtimeType, scheduleId, exceptionDate, exceptionHours);

  @override
  String toString() =>
      'DateExceptionAddedEvent(scheduleId: $scheduleId, exceptionDate: $exceptionDate, exceptionHours: $exceptionHours)';
}

/// The date keeps an exception with different hours. Empty exception_hours mean that the whole date is unavailable.
///
/// Aggregate: `availability_schedule`.
final class DateExceptionChangedEvent extends HostSetupEvent {
  const DateExceptionChangedEvent({
    required this.scheduleId,
    required this.exceptionDate,
    required this.exceptionHours,
  });

  final ScheduleId scheduleId;
  final ExceptionDate exceptionDate;
  final ExceptionHours exceptionHours;

  @override
  bool operator ==(Object other) =>
      other is DateExceptionChangedEvent &&
      other.scheduleId == scheduleId &&
      other.exceptionDate == exceptionDate &&
      other.exceptionHours == exceptionHours;

  @override
  int get hashCode => Object.hash(runtimeType, scheduleId, exceptionDate, exceptionHours);

  @override
  String toString() =>
      'DateExceptionChangedEvent(scheduleId: $scheduleId, exceptionDate: $exceptionDate, exceptionHours: $exceptionHours)';
}

/// The date goes back to the schedule's weekly hours.
///
/// Aggregate: `availability_schedule`.
final class DateExceptionRemovedEvent extends HostSetupEvent {
  const DateExceptionRemovedEvent({required this.scheduleId, required this.exceptionDate});

  final ScheduleId scheduleId;
  final ExceptionDate exceptionDate;

  @override
  bool operator ==(Object other) =>
      other is DateExceptionRemovedEvent && other.scheduleId == scheduleId && other.exceptionDate == exceptionDate;

  @override
  int get hashCode => Object.hash(runtimeType, scheduleId, exceptionDate);

  @override
  String toString() => 'DateExceptionRemovedEvent(scheduleId: $scheduleId, exceptionDate: $exceptionDate)';
}

/// The `booking_limits_set` event.
///
/// Aggregate: `availability_schedule`.
final class BookingLimitsSetEvent extends HostSetupEvent {
  const BookingLimitsSetEvent({
    required this.scheduleId,
    required this.bookingWindowDays,
    required this.minimumNoticeMinutes,
    required this.bufferBeforeMinutes,
    required this.bufferAfterMinutes,
  });

  final ScheduleId scheduleId;
  final BookingWindowDays bookingWindowDays;
  final MinimumNoticeMinutes minimumNoticeMinutes;
  final BufferBeforeMinutes bufferBeforeMinutes;
  final BufferAfterMinutes bufferAfterMinutes;

  @override
  bool operator ==(Object other) =>
      other is BookingLimitsSetEvent &&
      other.scheduleId == scheduleId &&
      other.bookingWindowDays == bookingWindowDays &&
      other.minimumNoticeMinutes == minimumNoticeMinutes &&
      other.bufferBeforeMinutes == bufferBeforeMinutes &&
      other.bufferAfterMinutes == bufferAfterMinutes;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    scheduleId,
    bookingWindowDays,
    minimumNoticeMinutes,
    bufferBeforeMinutes,
    bufferAfterMinutes,
  );

  @override
  String toString() =>
      'BookingLimitsSetEvent(scheduleId: $scheduleId, bookingWindowDays: $bookingWindowDays, minimumNoticeMinutes: $minimumNoticeMinutes, bufferBeforeMinutes: $bufferBeforeMinutes, bufferAfterMinutes: $bufferAfterMinutes)';
}

/// The `meeting_type_created` event.
///
/// Aggregate: `meeting_type`.
final class MeetingTypeCreatedEvent extends HostSetupEvent {
  const MeetingTypeCreatedEvent({
    required this.meetingTypeId,
    required this.hostId,
    required this.meetingTitle,
    required this.durationMinutes,
    required this.meetingLocation,
    required this.scheduleId,
    required this.bookingUrl,
    this.meetingDescription,
  });

  final MeetingTypeId meetingTypeId;
  final HostId hostId;
  final MeetingTitle meetingTitle;
  final DurationMinutes durationMinutes;
  final MeetingLocation meetingLocation;
  final ScheduleId scheduleId;
  final BookingUrl bookingUrl;
  final MeetingDescription? meetingDescription;

  @override
  bool operator ==(Object other) =>
      other is MeetingTypeCreatedEvent &&
      other.meetingTypeId == meetingTypeId &&
      other.hostId == hostId &&
      other.meetingTitle == meetingTitle &&
      other.durationMinutes == durationMinutes &&
      other.meetingLocation == meetingLocation &&
      other.scheduleId == scheduleId &&
      other.bookingUrl == bookingUrl &&
      other.meetingDescription == meetingDescription;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    meetingTypeId,
    hostId,
    meetingTitle,
    durationMinutes,
    meetingLocation,
    scheduleId,
    bookingUrl,
    meetingDescription,
  );

  @override
  String toString() =>
      'MeetingTypeCreatedEvent(meetingTypeId: $meetingTypeId, hostId: $hostId, meetingTitle: $meetingTitle, durationMinutes: $durationMinutes, meetingLocation: $meetingLocation, scheduleId: $scheduleId, bookingUrl: $bookingUrl, meetingDescription: $meetingDescription)';
}

/// Carries no booking_url, because the link stays stable across edits.
///
/// Aggregate: `meeting_type`.
final class MeetingTypeEditedEvent extends HostSetupEvent {
  const MeetingTypeEditedEvent({
    required this.meetingTypeId,
    required this.meetingTitle,
    required this.durationMinutes,
    required this.meetingLocation,
    required this.scheduleId,
    this.meetingDescription,
  });

  final MeetingTypeId meetingTypeId;
  final MeetingTitle meetingTitle;
  final DurationMinutes durationMinutes;
  final MeetingLocation meetingLocation;
  final ScheduleId scheduleId;
  final MeetingDescription? meetingDescription;

  @override
  bool operator ==(Object other) =>
      other is MeetingTypeEditedEvent &&
      other.meetingTypeId == meetingTypeId &&
      other.meetingTitle == meetingTitle &&
      other.durationMinutes == durationMinutes &&
      other.meetingLocation == meetingLocation &&
      other.scheduleId == scheduleId &&
      other.meetingDescription == meetingDescription;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    meetingTypeId,
    meetingTitle,
    durationMinutes,
    meetingLocation,
    scheduleId,
    meetingDescription,
  );

  @override
  String toString() =>
      'MeetingTypeEditedEvent(meetingTypeId: $meetingTypeId, meetingTitle: $meetingTitle, durationMinutes: $durationMinutes, meetingLocation: $meetingLocation, scheduleId: $scheduleId, meetingDescription: $meetingDescription)';
}

/// The `meeting_type_disabled` event.
///
/// Aggregate: `meeting_type`.
final class MeetingTypeDisabledEvent extends HostSetupEvent {
  const MeetingTypeDisabledEvent({required this.meetingTypeId});

  final MeetingTypeId meetingTypeId;

  @override
  bool operator ==(Object other) => other is MeetingTypeDisabledEvent && other.meetingTypeId == meetingTypeId;

  @override
  int get hashCode => Object.hash(runtimeType, meetingTypeId);

  @override
  String toString() => 'MeetingTypeDisabledEvent(meetingTypeId: $meetingTypeId)';
}

/// The `meeting_type_enabled` event.
///
/// Aggregate: `meeting_type`.
final class MeetingTypeEnabledEvent extends HostSetupEvent {
  const MeetingTypeEnabledEvent({required this.meetingTypeId});

  final MeetingTypeId meetingTypeId;

  @override
  bool operator ==(Object other) => other is MeetingTypeEnabledEvent && other.meetingTypeId == meetingTypeId;

  @override
  int get hashCode => Object.hash(runtimeType, meetingTypeId);

  @override
  String toString() => 'MeetingTypeEnabledEvent(meetingTypeId: $meetingTypeId)';
}

/// The `meeting_type_deleted` event.
///
/// Aggregate: `meeting_type`.
final class MeetingTypeDeletedEvent extends HostSetupEvent {
  const MeetingTypeDeletedEvent({required this.meetingTypeId});

  final MeetingTypeId meetingTypeId;

  @override
  bool operator ==(Object other) => other is MeetingTypeDeletedEvent && other.meetingTypeId == meetingTypeId;

  @override
  int get hashCode => Object.hash(runtimeType, meetingTypeId);

  @override
  String toString() => 'MeetingTypeDeletedEvent(meetingTypeId: $meetingTypeId)';
}
