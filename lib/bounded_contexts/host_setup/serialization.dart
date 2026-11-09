/// JSON codec and event contract of the `host_setup` bounded context.
library;

import '../event_contract.dart';
import 'event_tags.dart';
import 'events.dart';
import 'value_objects.dart';

/// The event contract of the `host_setup` bounded context.
const hostSetupEventContract = EventContract<HostSetupEvent>(
  context: 'host_setup',
  types: {
    'CalendarConnectionStartedEvent': CalendarConnectionStartedEvent,
    'CalendarConnectedEvent': CalendarConnectedEvent,
    'CalendarConnectionFailedEvent': CalendarConnectionFailedEvent,
    'HostBusyTimesRecordedEvent': HostBusyTimesRecordedEvent,
    'AvailabilityScheduleCreatedEvent': AvailabilityScheduleCreatedEvent,
    'WeeklyHoursSetEvent': WeeklyHoursSetEvent,
    'DateExceptionAddedEvent': DateExceptionAddedEvent,
    'DateExceptionChangedEvent': DateExceptionChangedEvent,
    'DateExceptionRemovedEvent': DateExceptionRemovedEvent,
    'BookingLimitsSetEvent': BookingLimitsSetEvent,
    'MeetingTypeCreatedEvent': MeetingTypeCreatedEvent,
    'MeetingTypeEditedEvent': MeetingTypeEditedEvent,
    'MeetingTypeDisabledEvent': MeetingTypeDisabledEvent,
    'MeetingTypeEnabledEvent': MeetingTypeEnabledEvent,
    'MeetingTypeDeletedEvent': MeetingTypeDeletedEvent,
  },
  typeName: hostSetupEventTypeName,
  stream: hostSetupEventStream,
  tags: hostSetupEventTags,
  encode: encodeHostSetupEvent,
  decode: decodeHostSetupEvent,
);

/// The JSON form of [e]. Keys are camelCase field names.
JsonMap encodeHostSetupEvent(HostSetupEvent e) => switch (e) {
  final CalendarConnectionStartedEvent e => <String, Object?>{'hostId': e.hostId.value},
  final CalendarConnectedEvent e => <String, Object?>{
    'hostId': e.hostId.value,
    'calendarAccount': e.calendarAccount.value,
  },
  final CalendarConnectionFailedEvent e => <String, Object?>{
    'hostId': e.hostId.value,
    'connectionFailure': e.connectionFailure.value,
  },
  final HostBusyTimesRecordedEvent e => <String, Object?>{
    'hostId': e.hostId.value,
    'busyIntervals': _encodeBusyIntervals(e.busyIntervals),
  },
  final AvailabilityScheduleCreatedEvent e => <String, Object?>{
    'scheduleId': e.scheduleId.value,
    'hostId': e.hostId.value,
    'scheduleName': e.scheduleName.value,
    'timeZone': e.timeZone.value,
  },
  final WeeklyHoursSetEvent e => <String, Object?>{
    'scheduleId': e.scheduleId.value,
    'weeklyHours': _encodeWeeklyHours(e.weeklyHours),
  },
  final DateExceptionAddedEvent e => <String, Object?>{
    'scheduleId': e.scheduleId.value,
    'exceptionDate': _encodeDate(e.exceptionDate.value),
    'exceptionHours': _encodeExceptionHours(e.exceptionHours),
  },
  final DateExceptionChangedEvent e => <String, Object?>{
    'scheduleId': e.scheduleId.value,
    'exceptionDate': _encodeDate(e.exceptionDate.value),
    'exceptionHours': _encodeExceptionHours(e.exceptionHours),
  },
  final DateExceptionRemovedEvent e => <String, Object?>{
    'scheduleId': e.scheduleId.value,
    'exceptionDate': _encodeDate(e.exceptionDate.value),
  },
  final BookingLimitsSetEvent e => <String, Object?>{
    'scheduleId': e.scheduleId.value,
    'bookingWindowDays': e.bookingWindowDays.value,
    'minimumNoticeMinutes': e.minimumNoticeMinutes.value,
    'bufferBeforeMinutes': e.bufferBeforeMinutes.value,
    'bufferAfterMinutes': e.bufferAfterMinutes.value,
  },
  final MeetingTypeCreatedEvent e => <String, Object?>{
    'meetingTypeId': e.meetingTypeId.value,
    'hostId': e.hostId.value,
    'meetingTitle': e.meetingTitle.value,
    'durationMinutes': e.durationMinutes.value,
    'meetingLocation': e.meetingLocation.value,
    'scheduleId': e.scheduleId.value,
    'bookingUrl': e.bookingUrl.value,
    'meetingDescription': e.meetingDescription?.value,
  },
  final MeetingTypeEditedEvent e => <String, Object?>{
    'meetingTypeId': e.meetingTypeId.value,
    'meetingTitle': e.meetingTitle.value,
    'durationMinutes': e.durationMinutes.value,
    'meetingLocation': e.meetingLocation.value,
    'scheduleId': e.scheduleId.value,
    'meetingDescription': e.meetingDescription?.value,
  },
  final MeetingTypeDisabledEvent e => <String, Object?>{'meetingTypeId': e.meetingTypeId.value},
  final MeetingTypeEnabledEvent e => <String, Object?>{'meetingTypeId': e.meetingTypeId.value},
  final MeetingTypeDeletedEvent e => <String, Object?>{'meetingTypeId': e.meetingTypeId.value},
};

/// The event of type [typeName] that [json] encodes.
///
/// Throws [ArgumentError] for an unknown [typeName].
HostSetupEvent decodeHostSetupEvent(String typeName, JsonMap json) => switch (typeName) {
  'CalendarConnectionStartedEvent' => CalendarConnectionStartedEvent(hostId: HostId(json['hostId'] as String)),
  'CalendarConnectedEvent' => CalendarConnectedEvent(
    hostId: HostId(json['hostId'] as String),
    calendarAccount: CalendarAccount(json['calendarAccount'] as String),
  ),
  'CalendarConnectionFailedEvent' => CalendarConnectionFailedEvent(
    hostId: HostId(json['hostId'] as String),
    connectionFailure: ConnectionFailure(json['connectionFailure'] as String),
  ),
  'HostBusyTimesRecordedEvent' => HostBusyTimesRecordedEvent(
    hostId: HostId(json['hostId'] as String),
    busyIntervals: _decodeBusyIntervals(json['busyIntervals'] as List<Object?>),
  ),
  'AvailabilityScheduleCreatedEvent' => AvailabilityScheduleCreatedEvent(
    scheduleId: ScheduleId(json['scheduleId'] as String),
    hostId: HostId(json['hostId'] as String),
    scheduleName: ScheduleName(json['scheduleName'] as String),
    timeZone: TimeZone(json['timeZone'] as String),
  ),
  'WeeklyHoursSetEvent' => WeeklyHoursSetEvent(
    scheduleId: ScheduleId(json['scheduleId'] as String),
    weeklyHours: _decodeWeeklyHours(json['weeklyHours'] as List<Object?>),
  ),
  'DateExceptionAddedEvent' => DateExceptionAddedEvent(
    scheduleId: ScheduleId(json['scheduleId'] as String),
    exceptionDate: ExceptionDate(_decodeDate(json['exceptionDate'] as String)),
    exceptionHours: _decodeExceptionHours(json['exceptionHours'] as List<Object?>),
  ),
  'DateExceptionChangedEvent' => DateExceptionChangedEvent(
    scheduleId: ScheduleId(json['scheduleId'] as String),
    exceptionDate: ExceptionDate(_decodeDate(json['exceptionDate'] as String)),
    exceptionHours: _decodeExceptionHours(json['exceptionHours'] as List<Object?>),
  ),
  'DateExceptionRemovedEvent' => DateExceptionRemovedEvent(
    scheduleId: ScheduleId(json['scheduleId'] as String),
    exceptionDate: ExceptionDate(_decodeDate(json['exceptionDate'] as String)),
  ),
  'BookingLimitsSetEvent' => BookingLimitsSetEvent(
    scheduleId: ScheduleId(json['scheduleId'] as String),
    bookingWindowDays: BookingWindowDays(json['bookingWindowDays'] as int),
    minimumNoticeMinutes: MinimumNoticeMinutes(json['minimumNoticeMinutes'] as int),
    bufferBeforeMinutes: BufferBeforeMinutes(json['bufferBeforeMinutes'] as int),
    bufferAfterMinutes: BufferAfterMinutes(json['bufferAfterMinutes'] as int),
  ),
  'MeetingTypeCreatedEvent' => MeetingTypeCreatedEvent(
    meetingTypeId: MeetingTypeId(json['meetingTypeId'] as String),
    hostId: HostId(json['hostId'] as String),
    meetingTitle: MeetingTitle(json['meetingTitle'] as String),
    durationMinutes: DurationMinutes(json['durationMinutes'] as int),
    meetingLocation: MeetingLocation(json['meetingLocation'] as String),
    scheduleId: ScheduleId(json['scheduleId'] as String),
    bookingUrl: BookingUrl(json['bookingUrl'] as String),
    meetingDescription: json['meetingDescription'] == null
        ? null
        : MeetingDescription(json['meetingDescription'] as String),
  ),
  'MeetingTypeEditedEvent' => MeetingTypeEditedEvent(
    meetingTypeId: MeetingTypeId(json['meetingTypeId'] as String),
    meetingTitle: MeetingTitle(json['meetingTitle'] as String),
    durationMinutes: DurationMinutes(json['durationMinutes'] as int),
    meetingLocation: MeetingLocation(json['meetingLocation'] as String),
    scheduleId: ScheduleId(json['scheduleId'] as String),
    meetingDescription: json['meetingDescription'] == null
        ? null
        : MeetingDescription(json['meetingDescription'] as String),
  ),
  'MeetingTypeDisabledEvent' => MeetingTypeDisabledEvent(meetingTypeId: MeetingTypeId(json['meetingTypeId'] as String)),
  'MeetingTypeEnabledEvent' => MeetingTypeEnabledEvent(meetingTypeId: MeetingTypeId(json['meetingTypeId'] as String)),
  'MeetingTypeDeletedEvent' => MeetingTypeDeletedEvent(meetingTypeId: MeetingTypeId(json['meetingTypeId'] as String)),
  _ => throw ArgumentError.value(typeName, 'typeName', 'Unknown host_setup event type'),
};

List<JsonMap> _encodeBusyIntervals(BusyIntervals v) => [
  for (final i in v.items)
    <String, Object?>{
      'busyFrom': i.busyFrom.toUtc().toIso8601String(),
      'busyUntil': i.busyUntil.toUtc().toIso8601String(),
    },
];

BusyIntervals _decodeBusyIntervals(List<Object?> json) => BusyIntervals([
  for (final m in json.cast<JsonMap>())
    BusyInterval(
      busyFrom: DateTime.parse(m['busyFrom'] as String).toUtc(),
      busyUntil: DateTime.parse(m['busyUntil'] as String).toUtc(),
    ),
]);

List<JsonMap> _encodeWeeklyHours(WeeklyHours v) => [
  for (final i in v.items) <String, Object?>{'weekday': i.weekday, 'startTime': i.startTime, 'endTime': i.endTime},
];

WeeklyHours _decodeWeeklyHours(List<Object?> json) => WeeklyHours([
  for (final m in json.cast<JsonMap>())
    WeeklyHoursEntry(
      weekday: m['weekday'] as String,
      startTime: m['startTime'] as String,
      endTime: m['endTime'] as String,
    ),
]);

List<JsonMap> _encodeExceptionHours(ExceptionHours v) => [
  for (final i in v.items) <String, Object?>{'startTime': i.startTime, 'endTime': i.endTime},
];

ExceptionHours _decodeExceptionHours(List<Object?> json) => ExceptionHours([
  for (final m in json.cast<JsonMap>())
    ExceptionHoursRange(startTime: m['startTime'] as String, endTime: m['endTime'] as String),
]);

String _encodeDate(DateTime d) {
  final u = d;
  return '${u.year.toString().padLeft(4, '0')}-${u.month.toString().padLeft(2, '0')}-${u.day.toString().padLeft(2, '0')}';
}

DateTime _decodeDate(String s) {
  final d = DateTime.parse(s);
  return DateTime.utc(d.year, d.month, d.day);
}
