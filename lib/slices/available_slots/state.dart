import '../../bounded_contexts/host_setup/api.dart';
import '../../bounded_contexts/meetings/api.dart';
import '../../ui/format.dart';

/// The read model `available_slots`: the inputs of the slot calculation for one host, kept in one document so that a
/// single state answers "Which times can a booker take?" for any of the host's meeting types.
///
/// The document holds the host's schedules, meeting types, busy times, calendar status, and held meetings. Meeting
/// types and held meetings are keyed by id, so that a query can find the host document from a meeting type id or a
/// meeting id.
final class AvailableSlotsState {
  const AvailableSlotsState({
    required this.hostId,
    this.hostName = '',
    this.calendarFailed = false,
    this.busy = const [],
    this.schedules = const {},
    this.meetingTypes = const {},
    this.meetings = const {},
  });

  factory AvailableSlotsState.empty(String hostId) => AvailableSlotsState(hostId: hostId);

  factory AvailableSlotsState.fromJson(JsonMap json) => AvailableSlotsState(
    hostId: json['hostId']! as String,
    hostName: json['hostName']! as String,
    calendarFailed: json['calendarFailed']! as bool,
    busy: [for (final range in json['busy']! as List) _rangeFromJson(range! as JsonMap)],
    schedules: {
      for (final e in (json['schedules']! as JsonMap).entries) e.key: ScheduleState.fromJson(e.value! as JsonMap),
    },
    meetingTypes: {
      for (final e in (json['meetingTypes']! as JsonMap).entries) e.key: MeetingTypeState.fromJson(e.value! as JsonMap),
    },
    meetings: {
      for (final e in (json['meetings']! as JsonMap).entries) e.key: HeldMeeting.fromJson(e.value! as JsonMap),
    },
  );

  final String hostId;
  final String hostName;

  /// True after `calendar_connection_failed` until the next `calendar_connected`.
  final bool calendarFailed;

  /// The busy times of the last `host_busy_times_recorded`.
  final List<TimeRange> busy;

  /// Keyed by schedule id.
  final Map<String, ScheduleState> schedules;

  /// Keyed by meeting type id.
  final Map<String, MeetingTypeState> meetingTypes;

  /// Keyed by meeting id. Holds every meeting that still occupies time.
  final Map<String, HeldMeeting> meetings;

  AvailableSlotsState copyWith({
    String? hostName,
    bool? calendarFailed,
    List<TimeRange>? busy,
    Map<String, ScheduleState>? schedules,
    Map<String, MeetingTypeState>? meetingTypes,
    Map<String, HeldMeeting>? meetings,
  }) => AvailableSlotsState(
    hostId: hostId,
    hostName: hostName ?? this.hostName,
    calendarFailed: calendarFailed ?? this.calendarFailed,
    busy: busy ?? this.busy,
    schedules: schedules ?? this.schedules,
    meetingTypes: meetingTypes ?? this.meetingTypes,
    meetings: meetings ?? this.meetings,
  );

  /// The slots a booker can take for [meetingTypeId] now, computed by the host's availability rules. Ranges held by
  /// the meeting [exceptMeetingId] are not counted, so that a meeting can move to a slot it already occupies.
  ///
  /// Returns no slots when the meeting type or its schedule is unknown.
  AvailableSlots slotsOf(String meetingTypeId, DateTime now, {String? exceptMeetingId}) {
    final meetingType = meetingTypes[meetingTypeId];
    final schedule = meetingType == null ? null : schedules[meetingType.scheduleId];
    if (meetingType == null || schedule == null) return AvailableSlots(const []);
    final ranges = availableSlots(
      rules: schedule.toRules(),
      duration: Duration(minutes: meetingType.durationMinutes),
      now: now,
      busy: busy,
      held: [
        for (final entry in meetings.entries)
          if (entry.key != exceptMeetingId) ...entry.value.occupiedRanges,
      ],
      calendarFailed: calendarFailed,
    );
    return AvailableSlots([for (final range in ranges) AvailableSlot(startAt: range.start, endAt: range.end)]);
  }

  JsonMap toJson() => {
    'hostId': hostId,
    'hostName': hostName,
    'calendarFailed': calendarFailed,
    'busy': [for (final range in busy) _rangeToJson(range)],
    'schedules': {for (final e in schedules.entries) e.key: e.value.toJson()},
    'meetingTypes': {for (final e in meetingTypes.entries) e.key: e.value.toJson()},
    'meetings': {for (final e in meetings.entries) e.key: e.value.toJson()},
  };

  @override
  bool operator ==(Object other) => other is AvailableSlotsState && _sameJson(other.toJson(), toJson());

  @override
  int get hashCode => hostId.hashCode;

  @override
  String toString() => 'AvailableSlotsState(${toJson()})';
}

/// The availability rules of one schedule, in the shape that `AvailabilityRules` needs.
final class ScheduleState {
  const ScheduleState({
    required this.timeZone,
    this.weeklyHours = const [],
    this.dateExceptions = const {},
    this.bookingWindowDays,
    this.minimumNoticeMinutes = 0,
    this.bufferBeforeMinutes = 0,
    this.bufferAfterMinutes = 0,
  });

  factory ScheduleState.fromJson(JsonMap json) => ScheduleState(
    timeZone: json['timeZone']! as String,
    weeklyHours: [
      for (final entry in json['weeklyHours']! as List)
        WeeklyHoursEntry(
          weekday: (entry! as JsonMap)['weekday']! as String,
          startTime: entry['startTime']! as String,
          endTime: entry['endTime']! as String,
        ),
    ],
    dateExceptions: {
      for (final e in (json['dateExceptions']! as JsonMap).entries)
        e.key: [for (final range in e.value! as List) _exceptionRangeFromJson(range! as JsonMap)],
    },
    bookingWindowDays: json['bookingWindowDays'] as int?,
    minimumNoticeMinutes: json['minimumNoticeMinutes']! as int,
    bufferBeforeMinutes: json['bufferBeforeMinutes']! as int,
    bufferAfterMinutes: json['bufferAfterMinutes']! as int,
  );

  final String timeZone;
  final List<WeeklyHoursEntry> weeklyHours;

  /// Keyed by the exception date as `yyyy-MM-dd`.
  final Map<String, List<ExceptionHoursRange>> dateExceptions;
  final int? bookingWindowDays;
  final int minimumNoticeMinutes;
  final int bufferBeforeMinutes;
  final int bufferAfterMinutes;

  ScheduleState withWeeklyHours(List<WeeklyHoursEntry> value) => ScheduleState(
    timeZone: timeZone,
    weeklyHours: value,
    dateExceptions: dateExceptions,
    bookingWindowDays: bookingWindowDays,
    minimumNoticeMinutes: minimumNoticeMinutes,
    bufferBeforeMinutes: bufferBeforeMinutes,
    bufferAfterMinutes: bufferAfterMinutes,
  );

  ScheduleState withDateException(String date, List<ExceptionHoursRange> hours) => ScheduleState(
    timeZone: timeZone,
    weeklyHours: weeklyHours,
    dateExceptions: {...dateExceptions, date: hours},
    bookingWindowDays: bookingWindowDays,
    minimumNoticeMinutes: minimumNoticeMinutes,
    bufferBeforeMinutes: bufferBeforeMinutes,
    bufferAfterMinutes: bufferAfterMinutes,
  );

  ScheduleState withoutDateException(String date) => ScheduleState(
    timeZone: timeZone,
    weeklyHours: weeklyHours,
    dateExceptions: {...dateExceptions}..remove(date),
    bookingWindowDays: bookingWindowDays,
    minimumNoticeMinutes: minimumNoticeMinutes,
    bufferBeforeMinutes: bufferBeforeMinutes,
    bufferAfterMinutes: bufferAfterMinutes,
  );

  ScheduleState withLimits({
    required int bookingWindowDays,
    required int minimumNoticeMinutes,
    required int bufferBeforeMinutes,
    required int bufferAfterMinutes,
  }) => ScheduleState(
    timeZone: timeZone,
    weeklyHours: weeklyHours,
    dateExceptions: dateExceptions,
    bookingWindowDays: bookingWindowDays,
    minimumNoticeMinutes: minimumNoticeMinutes,
    bufferBeforeMinutes: bufferBeforeMinutes,
    bufferAfterMinutes: bufferAfterMinutes,
  );

  AvailabilityRules toRules() => AvailabilityRules(
    timeZone: timeZone,
    weeklyHours: weeklyHours,
    dateExceptions: {
      for (final e in dateExceptions.entries) _dateFromKey(e.key): e.value,
    },
    bookingWindowDays: bookingWindowDays,
    minimumNoticeMinutes: minimumNoticeMinutes,
    bufferBeforeMinutes: bufferBeforeMinutes,
    bufferAfterMinutes: bufferAfterMinutes,
  );

  JsonMap toJson() => {
    'timeZone': timeZone,
    'weeklyHours': [
      for (final entry in weeklyHours)
        {'weekday': entry.weekday, 'startTime': entry.startTime, 'endTime': entry.endTime},
    ],
    'dateExceptions': {
      for (final e in dateExceptions.entries)
        e.key: [
          for (final range in e.value) {'startTime': range.startTime, 'endTime': range.endTime},
        ],
    },
    'bookingWindowDays': bookingWindowDays,
    'minimumNoticeMinutes': minimumNoticeMinutes,
    'bufferBeforeMinutes': bufferBeforeMinutes,
    'bufferAfterMinutes': bufferAfterMinutes,
  };
}

/// The parts of a meeting type that a booking page and a reschedule picker show or need. A deleted meeting type keeps
/// its entry with [accepting] false, because a booked meeting of it can still be rescheduled.
final class MeetingTypeState {
  const MeetingTypeState({
    required this.scheduleId,
    required this.title,
    required this.durationMinutes,
    required this.location,
    required this.description,
    required this.accepting,
  });

  factory MeetingTypeState.fromJson(JsonMap json) => MeetingTypeState(
    scheduleId: json['scheduleId']! as String,
    title: json['title']! as String,
    durationMinutes: json['durationMinutes']! as int,
    location: json['location']! as String,
    description: json['description'] as String?,
    accepting: json['accepting']! as bool,
  );

  final String scheduleId;
  final String title;
  final int durationMinutes;
  final String location;
  final String? description;

  /// True while the meeting type is created or enabled. Only the booking page checks it.
  final bool accepting;

  MeetingTypeState withDetails({
    required String scheduleId,
    required String title,
    required int durationMinutes,
    required String location,
    required String? description,
  }) => MeetingTypeState(
    scheduleId: scheduleId,
    title: title,
    durationMinutes: durationMinutes,
    location: location,
    description: description,
    accepting: accepting,
  );

  MeetingTypeState withAccepting(bool value) => MeetingTypeState(
    scheduleId: scheduleId,
    title: title,
    durationMinutes: durationMinutes,
    location: location,
    description: description,
    accepting: value,
  );

  JsonMap toJson() => {
    'scheduleId': scheduleId,
    'title': title,
    'durationMinutes': durationMinutes,
    'location': location,
    'description': description,
    'accepting': accepting,
  };
}

/// A meeting that still occupies time. [current] is the slot the meeting holds. [pending] is the slot a requested
/// reschedule would move it to; it is held too until the reschedule settles.
final class HeldMeeting {
  const HeldMeeting({required this.meetingTypeId, required this.bookerId, required this.current, this.pending});

  factory HeldMeeting.fromJson(JsonMap json) => HeldMeeting(
    meetingTypeId: json['meetingTypeId']! as String,
    bookerId: json['bookerId']! as String,
    current: _rangeFromJson(json['current']! as JsonMap),
    pending: json['pending'] == null ? null : _rangeFromJson(json['pending']! as JsonMap),
  );

  final String meetingTypeId;
  final String bookerId;
  final TimeRange current;
  final TimeRange? pending;

  /// Every range the meeting occupies: the current slot, and the pending slot if a reschedule is open.
  List<TimeRange> get occupiedRanges => [current, ?pending];

  HeldMeeting withPending(TimeRange? value) =>
      HeldMeeting(meetingTypeId: meetingTypeId, bookerId: bookerId, current: current, pending: value);

  /// A reschedule was completed: the pending slot becomes the current slot.
  HeldMeeting settled() => HeldMeeting(meetingTypeId: meetingTypeId, bookerId: bookerId, current: pending ?? current);

  /// The calendar moved the meeting directly to [range].
  HeldMeeting movedTo(TimeRange range) => HeldMeeting(meetingTypeId: meetingTypeId, bookerId: bookerId, current: range);

  JsonMap toJson() => {
    'meetingTypeId': meetingTypeId,
    'bookerId': bookerId,
    'current': _rangeToJson(current),
    'pending': pending == null ? null : _rangeToJson(pending!),
  };
}

/// The key of a schedule's date exception, from its UTC midnight.
String dateKey(DateTime date) => isoDate(date);

DateTime _dateFromKey(String key) => DateTime.utc(
  int.parse(key.substring(0, 4)),
  int.parse(key.substring(5, 7)),
  int.parse(key.substring(8, 10)),
);

JsonMap _rangeToJson(TimeRange range) => {
  'start': range.start.toUtc().toIso8601String(),
  'end': range.end.toUtc().toIso8601String(),
};

TimeRange _rangeFromJson(JsonMap json) => (
  start: DateTime.parse(json['start']! as String),
  end: DateTime.parse(json['end']! as String),
);

ExceptionHoursRange _exceptionRangeFromJson(JsonMap json) =>
    ExceptionHoursRange(startTime: json['startTime']! as String, endTime: json['endTime']! as String);

/// Structural equality of two JSON values, independent of map key order.
bool _sameJson(Object? a, Object? b) {
  if (a is Map && b is Map) {
    return a.length == b.length && a.keys.every((k) => b.containsKey(k) && _sameJson(a[k], b[k]));
  }
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!_sameJson(a[i], b[i])) return false;
    }
    return true;
  }
  return a == b;
}
