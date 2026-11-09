/// Value objects of the `host_setup` bounded context.
library;

/// The `host_id` field type (String, identity).
///
/// Example: `alice-employee-id`.
extension type const HostId._(String value) {
  factory HostId(String value) {
    if (value.isEmpty) {
      throw ArgumentError.value(value, 'value', 'HostId must not be empty');
    }
    return HostId._(value);
  }
}

/// The `calendar_account` field type (String).
extension type const CalendarAccount._(String value) {
  factory CalendarAccount(String value) => CalendarAccount._(value);
}

/// The `connection_failure` field type (String).
extension type const ConnectionFailure._(String value) {
  factory ConnectionFailure(String value) => ConnectionFailure._(value);
}

/// One entry of the `busy_intervals` field type.
final class BusyInterval {
  const BusyInterval({required this.busyFrom, required this.busyUntil});

  final DateTime busyFrom;
  final DateTime busyUntil;

  @override
  bool operator ==(Object other) => other is BusyInterval && other.busyFrom == busyFrom && other.busyUntil == busyUntil;

  @override
  int get hashCode => Object.hash(runtimeType, busyFrom, busyUntil);

  @override
  String toString() => 'BusyInterval(busyFrom: $busyFrom, busyUntil: $busyUntil)';
}

/// The `busy_intervals` field type: a list of [BusyInterval].
final class BusyIntervals {
  BusyIntervals(Iterable<BusyInterval> items) : items = List.unmodifiable(items);

  /// An empty list.
  const BusyIntervals.empty() : items = const [];

  final List<BusyInterval> items;

  @override
  bool operator ==(Object other) {
    if (other is! BusyIntervals || other.items.length != items.length) return false;
    for (var i = 0; i < items.length; i++) {
      if (other.items[i] != items[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(items);

  @override
  String toString() => 'BusyIntervals($items)';
}

/// The `schedule_id` field type (String, identity).
extension type const ScheduleId._(String value) {
  factory ScheduleId(String value) {
    if (value.isEmpty) {
      throw ArgumentError.value(value, 'value', 'ScheduleId must not be empty');
    }
    return ScheduleId._(value);
  }
}

/// The `schedule_name` field type (String).
///
/// Example: `Working hours`.
extension type const ScheduleName._(String value) {
  factory ScheduleName(String value) => ScheduleName._(value);
}

/// The `time_zone` field type (String).
///
/// Example: `Europe/Berlin`.
extension type const TimeZone._(String value) {
  factory TimeZone(String value) => TimeZone._(value);
}

/// One entry of the `weekly_hours` field type.
final class WeeklyHoursEntry {
  const WeeklyHoursEntry({required this.weekday, required this.startTime, required this.endTime});

  final String weekday;
  final String startTime;
  final String endTime;

  @override
  bool operator ==(Object other) =>
      other is WeeklyHoursEntry && other.weekday == weekday && other.startTime == startTime && other.endTime == endTime;

  @override
  int get hashCode => Object.hash(runtimeType, weekday, startTime, endTime);

  @override
  String toString() => 'WeeklyHoursEntry(weekday: $weekday, startTime: $startTime, endTime: $endTime)';
}

/// The `weekly_hours` field type: a list of [WeeklyHoursEntry].
final class WeeklyHours {
  WeeklyHours(Iterable<WeeklyHoursEntry> items) : items = List.unmodifiable(items);

  /// An empty list.
  const WeeklyHours.empty() : items = const [];

  final List<WeeklyHoursEntry> items;

  @override
  bool operator ==(Object other) {
    if (other is! WeeklyHours || other.items.length != items.length) return false;
    for (var i = 0; i < items.length; i++) {
      if (other.items[i] != items[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(items);

  @override
  String toString() => 'WeeklyHours($items)';
}

/// The `exception_date` field type (Date).
///
/// A calendar date, held as UTC midnight.
extension type const ExceptionDate._(DateTime value) {
  factory ExceptionDate(DateTime value) => ExceptionDate._(value);
}

/// One entry of the `exception_hours` field type.
final class ExceptionHoursRange {
  const ExceptionHoursRange({required this.startTime, required this.endTime});

  final String startTime;
  final String endTime;

  @override
  bool operator ==(Object other) =>
      other is ExceptionHoursRange && other.startTime == startTime && other.endTime == endTime;

  @override
  int get hashCode => Object.hash(runtimeType, startTime, endTime);

  @override
  String toString() => 'ExceptionHoursRange(startTime: $startTime, endTime: $endTime)';
}

/// The `exception_hours` field type: a list of [ExceptionHoursRange].
final class ExceptionHours {
  ExceptionHours(Iterable<ExceptionHoursRange> items) : items = List.unmodifiable(items);

  /// An empty list.
  const ExceptionHours.empty() : items = const [];

  final List<ExceptionHoursRange> items;

  @override
  bool operator ==(Object other) {
    if (other is! ExceptionHours || other.items.length != items.length) return false;
    for (var i = 0; i < items.length; i++) {
      if (other.items[i] != items[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(items);

  @override
  String toString() => 'ExceptionHours($items)';
}

/// One entry of the `date_exceptions` field type.
final class DateException {
  const DateException({required this.exceptionDate, required this.hours});

  final DateTime exceptionDate;
  final ExceptionHours hours;

  @override
  bool operator ==(Object other) =>
      other is DateException && other.exceptionDate == exceptionDate && other.hours == hours;

  @override
  int get hashCode => Object.hash(runtimeType, exceptionDate, hours);

  @override
  String toString() => 'DateException(exceptionDate: $exceptionDate, hours: $hours)';
}

/// The `date_exceptions` field type: a list of [DateException].
final class DateExceptions {
  DateExceptions(Iterable<DateException> items) : items = List.unmodifiable(items);

  /// An empty list.
  const DateExceptions.empty() : items = const [];

  final List<DateException> items;

  @override
  bool operator ==(Object other) {
    if (other is! DateExceptions || other.items.length != items.length) return false;
    for (var i = 0; i < items.length; i++) {
      if (other.items[i] != items[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(items);

  @override
  String toString() => 'DateExceptions($items)';
}

/// The `accepting_bookings` field type (Boolean).
extension type const AcceptingBookings._(bool value) {
  factory AcceptingBookings(bool value) => AcceptingBookings._(value);
}

/// The `booking_window_days` field type (Int).
extension type const BookingWindowDays._(int value) {
  factory BookingWindowDays(int value) => BookingWindowDays._(value);
}

/// The `minimum_notice_minutes` field type (Int).
extension type const MinimumNoticeMinutes._(int value) {
  factory MinimumNoticeMinutes(int value) => MinimumNoticeMinutes._(value);
}

/// The `buffer_before_minutes` field type (Int).
extension type const BufferBeforeMinutes._(int value) {
  factory BufferBeforeMinutes(int value) => BufferBeforeMinutes._(value);
}

/// The `buffer_after_minutes` field type (Int).
extension type const BufferAfterMinutes._(int value) {
  factory BufferAfterMinutes(int value) => BufferAfterMinutes._(value);
}

/// The `meeting_type_id` field type (String, identity).
extension type const MeetingTypeId._(String value) {
  factory MeetingTypeId(String value) {
    if (value.isEmpty) {
      throw ArgumentError.value(value, 'value', 'MeetingTypeId must not be empty');
    }
    return MeetingTypeId._(value);
  }
}

/// The `meeting_title` field type (String).
///
/// Example: `30-minute consultation`.
extension type const MeetingTitle._(String value) {
  factory MeetingTitle(String value) => MeetingTitle._(value);
}

/// The `meeting_description` field type (String).
extension type const MeetingDescription._(String value) {
  factory MeetingDescription(String value) => MeetingDescription._(value);
}

/// The `duration_minutes` field type (Int).
///
/// Example: `30`.
extension type const DurationMinutes._(int value) {
  factory DurationMinutes(int value) => DurationMinutes._(value);
}

/// The `meeting_location` field type (String).
extension type const MeetingLocation._(String value) {
  factory MeetingLocation(String value) => MeetingLocation._(value);
}

/// The `booking_url` field type (String).
extension type const BookingUrl._(String value) {
  factory BookingUrl(String value) => BookingUrl._(value);
}
