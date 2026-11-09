import '../../bounded_contexts/host_setup/api.dart';

/// The read model `my_availability_schedules`: the answer to "Which availability schedules have I defined, and what
/// are their rules?" for one schedule. Its key is the schedule id; the host id is kept so that a query can find the
/// schedules of one host.
///
/// The booking limits are null until `booking_limits_set` has been recorded for the schedule. The weekly hours and
/// the date exceptions start empty.
final class AvailabilitySchedule {
  const AvailabilitySchedule({
    required this.scheduleId,
    required this.hostId,
    required this.scheduleName,
    required this.timeZone,
    this.weeklyHours = const WeeklyHours.empty(),
    this.dateExceptions = const DateExceptions.empty(),
    this.bookingWindowDays,
    this.minimumNoticeMinutes,
    this.bufferBeforeMinutes,
    this.bufferAfterMinutes,
  });

  factory AvailabilitySchedule.fromJson(JsonMap json) => AvailabilitySchedule(
    scheduleId: ScheduleId(json['scheduleId']! as String),
    hostId: HostId(json['hostId']! as String),
    scheduleName: ScheduleName(json['scheduleName']! as String),
    timeZone: TimeZone(json['timeZone']! as String),
    weeklyHours: WeeklyHours([
      for (final entry in json['weeklyHours']! as List<Object?>) _weeklyHoursEntryFromJson(entry! as JsonMap),
    ]),
    dateExceptions: DateExceptions([
      for (final entry in json['dateExceptions']! as List<Object?>) _dateExceptionFromJson(entry! as JsonMap),
    ]),
    bookingWindowDays: switch (json['bookingWindowDays']) {
      final int days => BookingWindowDays(days),
      _ => null,
    },
    minimumNoticeMinutes: switch (json['minimumNoticeMinutes']) {
      final int minutes => MinimumNoticeMinutes(minutes),
      _ => null,
    },
    bufferBeforeMinutes: switch (json['bufferBeforeMinutes']) {
      final int minutes => BufferBeforeMinutes(minutes),
      _ => null,
    },
    bufferAfterMinutes: switch (json['bufferAfterMinutes']) {
      final int minutes => BufferAfterMinutes(minutes),
      _ => null,
    },
  );

  final ScheduleId scheduleId;
  final HostId hostId;
  final ScheduleName scheduleName;
  final TimeZone timeZone;
  final WeeklyHours weeklyHours;

  /// Sorted by date, with one entry per date.
  final DateExceptions dateExceptions;
  final BookingWindowDays? bookingWindowDays;
  final MinimumNoticeMinutes? minimumNoticeMinutes;
  final BufferBeforeMinutes? bufferBeforeMinutes;
  final BufferAfterMinutes? bufferAfterMinutes;

  AvailabilitySchedule withWeeklyHours(WeeklyHours hours) => _copy(weeklyHours: hours);

  /// Adds the exception of its date, or replaces the hours of the exception that the date already has.
  AvailabilitySchedule withDateException(DateException exception) {
    final items = [
      for (final existing in dateExceptions.items)
        if (existing.exceptionDate != exception.exceptionDate) existing,
      exception,
    ]..sort((a, b) => a.exceptionDate.compareTo(b.exceptionDate));
    return _copy(dateExceptions: DateExceptions(items));
  }

  /// The date goes back to the weekly hours.
  AvailabilitySchedule withoutDateException(DateTime date) => _copy(
    dateExceptions: DateExceptions([
      for (final existing in dateExceptions.items)
        if (existing.exceptionDate != date) existing,
    ]),
  );

  AvailabilitySchedule withBookingLimits({
    required BookingWindowDays bookingWindowDays,
    required MinimumNoticeMinutes minimumNoticeMinutes,
    required BufferBeforeMinutes bufferBeforeMinutes,
    required BufferAfterMinutes bufferAfterMinutes,
  }) => _copy(
    bookingWindowDays: bookingWindowDays,
    minimumNoticeMinutes: minimumNoticeMinutes,
    bufferBeforeMinutes: bufferBeforeMinutes,
    bufferAfterMinutes: bufferAfterMinutes,
  );

  AvailabilitySchedule _copy({
    WeeklyHours? weeklyHours,
    DateExceptions? dateExceptions,
    BookingWindowDays? bookingWindowDays,
    MinimumNoticeMinutes? minimumNoticeMinutes,
    BufferBeforeMinutes? bufferBeforeMinutes,
    BufferAfterMinutes? bufferAfterMinutes,
  }) => AvailabilitySchedule(
    scheduleId: scheduleId,
    hostId: hostId,
    scheduleName: scheduleName,
    timeZone: timeZone,
    weeklyHours: weeklyHours ?? this.weeklyHours,
    dateExceptions: dateExceptions ?? this.dateExceptions,
    bookingWindowDays: bookingWindowDays ?? this.bookingWindowDays,
    minimumNoticeMinutes: minimumNoticeMinutes ?? this.minimumNoticeMinutes,
    bufferBeforeMinutes: bufferBeforeMinutes ?? this.bufferBeforeMinutes,
    bufferAfterMinutes: bufferAfterMinutes ?? this.bufferAfterMinutes,
  );

  JsonMap toJson() => {
    'scheduleId': scheduleId.value,
    'hostId': hostId.value,
    'scheduleName': scheduleName.value,
    'timeZone': timeZone.value,
    'weeklyHours': [
      for (final entry in weeklyHours.items)
        {'weekday': entry.weekday, 'startTime': entry.startTime, 'endTime': entry.endTime},
    ],
    'dateExceptions': [
      for (final exception in dateExceptions.items)
        {
          'exceptionDate': exception.exceptionDate.toIso8601String(),
          'hours': [
            for (final range in exception.hours.items) {'startTime': range.startTime, 'endTime': range.endTime},
          ],
        },
    ],
    'bookingWindowDays': bookingWindowDays?.value,
    'minimumNoticeMinutes': minimumNoticeMinutes?.value,
    'bufferBeforeMinutes': bufferBeforeMinutes?.value,
    'bufferAfterMinutes': bufferAfterMinutes?.value,
  };

  @override
  bool operator ==(Object other) =>
      other is AvailabilitySchedule &&
      other.scheduleId == scheduleId &&
      other.hostId == hostId &&
      other.scheduleName == scheduleName &&
      other.timeZone == timeZone &&
      other.weeklyHours == weeklyHours &&
      other.dateExceptions == dateExceptions &&
      other.bookingWindowDays == bookingWindowDays &&
      other.minimumNoticeMinutes == minimumNoticeMinutes &&
      other.bufferBeforeMinutes == bufferBeforeMinutes &&
      other.bufferAfterMinutes == bufferAfterMinutes;

  @override
  int get hashCode => Object.hash(
    scheduleId,
    hostId,
    scheduleName,
    timeZone,
    weeklyHours,
    dateExceptions,
    bookingWindowDays,
    minimumNoticeMinutes,
    bufferBeforeMinutes,
    bufferAfterMinutes,
  );

  @override
  String toString() =>
      'AvailabilitySchedule(scheduleId: $scheduleId, hostId: $hostId, scheduleName: $scheduleName, timeZone: $timeZone, weeklyHours: $weeklyHours, dateExceptions: $dateExceptions, bookingWindowDays: $bookingWindowDays, minimumNoticeMinutes: $minimumNoticeMinutes, bufferBeforeMinutes: $bufferBeforeMinutes, bufferAfterMinutes: $bufferAfterMinutes)';
}

WeeklyHoursEntry _weeklyHoursEntryFromJson(JsonMap json) => WeeklyHoursEntry(
  weekday: json['weekday']! as String,
  startTime: json['startTime']! as String,
  endTime: json['endTime']! as String,
);

DateException _dateExceptionFromJson(JsonMap json) => DateException(
  exceptionDate: DateTime.parse(json['exceptionDate']! as String),
  hours: ExceptionHours([
    for (final range in json['hours']! as List<Object?>) _exceptionHoursRangeFromJson(range! as JsonMap),
  ]),
);

ExceptionHoursRange _exceptionHoursRangeFromJson(JsonMap json) => ExceptionHoursRange(
  startTime: json['startTime']! as String,
  endTime: json['endTime']! as String,
);
