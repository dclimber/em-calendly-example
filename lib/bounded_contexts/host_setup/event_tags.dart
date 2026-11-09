/// Type names, tags, and streams of the `host_setup` events.
library;

import '../event_contract.dart';
import 'events.dart';

/// The stable type name of [e]: its Dart class name.
String hostSetupEventTypeName(HostSetupEvent e) => switch (e) {
  CalendarConnectionStartedEvent() => 'CalendarConnectionStartedEvent',
  CalendarConnectedEvent() => 'CalendarConnectedEvent',
  CalendarConnectionFailedEvent() => 'CalendarConnectionFailedEvent',
  HostBusyTimesRecordedEvent() => 'HostBusyTimesRecordedEvent',
  AvailabilityScheduleCreatedEvent() => 'AvailabilityScheduleCreatedEvent',
  WeeklyHoursSetEvent() => 'WeeklyHoursSetEvent',
  DateExceptionAddedEvent() => 'DateExceptionAddedEvent',
  DateExceptionChangedEvent() => 'DateExceptionChangedEvent',
  DateExceptionRemovedEvent() => 'DateExceptionRemovedEvent',
  BookingLimitsSetEvent() => 'BookingLimitsSetEvent',
  MeetingTypeCreatedEvent() => 'MeetingTypeCreatedEvent',
  MeetingTypeEditedEvent() => 'MeetingTypeEditedEvent',
  MeetingTypeDisabledEvent() => 'MeetingTypeDisabledEvent',
  MeetingTypeEnabledEvent() => 'MeetingTypeEnabledEvent',
  MeetingTypeDeletedEvent() => 'MeetingTypeDeletedEvent',
};

/// The tags of [e]: identity fields, correlation keys, and deduplication keys.
List<EventTag> hostSetupEventTags(HostSetupEvent e) => switch (e) {
  final CalendarConnectionStartedEvent e => [(tag: 'hostId', value: e.hostId.value)],
  final CalendarConnectedEvent e => [(tag: 'hostId', value: e.hostId.value)],
  final CalendarConnectionFailedEvent e => [(tag: 'hostId', value: e.hostId.value)],
  final HostBusyTimesRecordedEvent e => [(tag: 'hostId', value: e.hostId.value)],
  final AvailabilityScheduleCreatedEvent e => [
    (tag: 'scheduleId', value: e.scheduleId.value),
    (tag: 'hostId', value: e.hostId.value),
  ],
  final WeeklyHoursSetEvent e => [(tag: 'scheduleId', value: e.scheduleId.value)],
  final DateExceptionAddedEvent e => [(tag: 'scheduleId', value: e.scheduleId.value)],
  final DateExceptionChangedEvent e => [(tag: 'scheduleId', value: e.scheduleId.value)],
  final DateExceptionRemovedEvent e => [(tag: 'scheduleId', value: e.scheduleId.value)],
  final BookingLimitsSetEvent e => [(tag: 'scheduleId', value: e.scheduleId.value)],
  final MeetingTypeCreatedEvent e => [
    (tag: 'meetingTypeId', value: e.meetingTypeId.value),
    (tag: 'hostId', value: e.hostId.value),
    (tag: 'scheduleId', value: e.scheduleId.value),
  ],
  final MeetingTypeEditedEvent e => [
    (tag: 'meetingTypeId', value: e.meetingTypeId.value),
    (tag: 'scheduleId', value: e.scheduleId.value),
  ],
  final MeetingTypeDisabledEvent e => [(tag: 'meetingTypeId', value: e.meetingTypeId.value)],
  final MeetingTypeEnabledEvent e => [(tag: 'meetingTypeId', value: e.meetingTypeId.value)],
  final MeetingTypeDeletedEvent e => [(tag: 'meetingTypeId', value: e.meetingTypeId.value)],
};

/// The fstore-sql stream of [e].
EventStream hostSetupEventStream(HostSetupEvent e) => switch (e) {
  final CalendarConnectionStartedEvent e => (type: 'calendar_connection', id: e.hostId.value),
  final CalendarConnectedEvent e => (type: 'calendar_connection', id: e.hostId.value),
  final CalendarConnectionFailedEvent e => (type: 'calendar_connection', id: e.hostId.value),
  final HostBusyTimesRecordedEvent e => (type: 'calendar_connection', id: e.hostId.value),
  final AvailabilityScheduleCreatedEvent e => (type: 'availability_schedule', id: e.scheduleId.value),
  final WeeklyHoursSetEvent e => (type: 'availability_schedule', id: e.scheduleId.value),
  final DateExceptionAddedEvent e => (type: 'availability_schedule', id: e.scheduleId.value),
  final DateExceptionChangedEvent e => (type: 'availability_schedule', id: e.scheduleId.value),
  final DateExceptionRemovedEvent e => (type: 'availability_schedule', id: e.scheduleId.value),
  final BookingLimitsSetEvent e => (type: 'availability_schedule', id: e.scheduleId.value),
  final MeetingTypeCreatedEvent e => (type: 'meeting_type', id: e.meetingTypeId.value),
  final MeetingTypeEditedEvent e => (type: 'meeting_type', id: e.meetingTypeId.value),
  final MeetingTypeDisabledEvent e => (type: 'meeting_type', id: e.meetingTypeId.value),
  final MeetingTypeEnabledEvent e => (type: 'meeting_type', id: e.meetingTypeId.value),
  final MeetingTypeDeletedEvent e => (type: 'meeting_type', id: e.meetingTypeId.value),
};
