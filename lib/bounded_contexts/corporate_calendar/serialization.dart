/// JSON codec and event contract of the `corporate_calendar` bounded context.
library;

import '../event_contract.dart';
import 'event_tags.dart';
import 'events.dart';
import 'value_objects.dart';

/// The event contract of the `corporate_calendar` bounded context.
const corporateCalendarEventContract = EventContract<CorporateCalendarEvent>(
  context: 'corporate_calendar',
  types: {
    'CalendarAccessGrantedEvent': CalendarAccessGrantedEvent,
    'CalendarAccessFailedEvent': CalendarAccessFailedEvent,
    'FreeBusyReportedEvent': FreeBusyReportedEvent,
    'CalendarEventCreatedEvent': CalendarEventCreatedEvent,
    'CalendarEventCreationFailedEvent': CalendarEventCreationFailedEvent,
    'CalendarEventUpdatedEvent': CalendarEventUpdatedEvent,
    'CalendarEventUpdateFailedEvent': CalendarEventUpdateFailedEvent,
    'CalendarEventDeletedEvent': CalendarEventDeletedEvent,
    'CalendarEventDeletionFailedEvent': CalendarEventDeletionFailedEvent,
    'HostSlotFoundFreeEvent': HostSlotFoundFreeEvent,
    'HostSlotFoundBusyEvent': HostSlotFoundBusyEvent,
    'AvailabilityCheckFailedEvent': AvailabilityCheckFailedEvent,
    'CalendarEventMovedDirectlyEvent': CalendarEventMovedDirectlyEvent,
    'CalendarEventDeletedDirectlyEvent': CalendarEventDeletedDirectlyEvent,
  },
  typeName: corporateCalendarEventTypeName,
  stream: corporateCalendarEventStream,
  tags: corporateCalendarEventTags,
  encode: encodeCorporateCalendarEvent,
  decode: decodeCorporateCalendarEvent,
);

/// The JSON form of [e]. Keys are camelCase field names.
JsonMap encodeCorporateCalendarEvent(CorporateCalendarEvent e) => switch (e) {
  final CalendarAccessGrantedEvent e => <String, Object?>{
    'schedulerUserRef': e.schedulerUserRef.value,
    'calendarAccount': e.calendarAccount,
  },
  final CalendarAccessFailedEvent e => <String, Object?>{
    'failureCode': e.failureCode.value,
    'schedulerUserRef': e.schedulerUserRef.value,
  },
  final FreeBusyReportedEvent e => <String, Object?>{
    'freeBusyBlocks': _encodeFreeBusyBlocks(e.freeBusyBlocks),
    'schedulerUserRef': e.schedulerUserRef.value,
  },
  final CalendarEventCreatedEvent e => <String, Object?>{
    'schedulerMeetingRef': e.schedulerMeetingRef.value,
    'providerEventRef': e.providerEventRef,
  },
  final CalendarEventCreationFailedEvent e => <String, Object?>{
    'failureCode': e.failureCode.value,
    'schedulerMeetingRef': e.schedulerMeetingRef.value,
  },
  final CalendarEventUpdatedEvent e => <String, Object?>{'schedulerMeetingRef': e.schedulerMeetingRef.value},
  final CalendarEventUpdateFailedEvent e => <String, Object?>{
    'failureCode': e.failureCode.value,
    'schedulerMeetingRef': e.schedulerMeetingRef.value,
  },
  final CalendarEventDeletedEvent e => <String, Object?>{'schedulerMeetingRef': e.schedulerMeetingRef.value},
  final CalendarEventDeletionFailedEvent e => <String, Object?>{
    'failureCode': e.failureCode.value,
    'schedulerMeetingRef': e.schedulerMeetingRef.value,
  },
  final HostSlotFoundFreeEvent e => <String, Object?>{'schedulerMeetingRef': e.schedulerMeetingRef.value},
  final HostSlotFoundBusyEvent e => <String, Object?>{'schedulerMeetingRef': e.schedulerMeetingRef.value},
  final AvailabilityCheckFailedEvent e => <String, Object?>{
    'failureCode': e.failureCode.value,
    'schedulerMeetingRef': e.schedulerMeetingRef.value,
  },
  final CalendarEventMovedDirectlyEvent e => <String, Object?>{
    'schedulerMeetingRef': e.schedulerMeetingRef.value,
    'movedStart': e.movedStart.toUtc().toIso8601String(),
    'movedEnd': e.movedEnd.toUtc().toIso8601String(),
  },
  final CalendarEventDeletedDirectlyEvent e => <String, Object?>{'schedulerMeetingRef': e.schedulerMeetingRef.value},
};

/// The event of type [typeName] that [json] encodes.
///
/// Throws [ArgumentError] for an unknown [typeName].
CorporateCalendarEvent decodeCorporateCalendarEvent(String typeName, JsonMap json) => switch (typeName) {
  'CalendarAccessGrantedEvent' => CalendarAccessGrantedEvent(
    schedulerUserRef: SchedulerUserRef(json['schedulerUserRef'] as String),
    calendarAccount: json['calendarAccount'] as String,
  ),
  'CalendarAccessFailedEvent' => CalendarAccessFailedEvent(
    failureCode: FailureCode(json['failureCode'] as String),
    schedulerUserRef: SchedulerUserRef(json['schedulerUserRef'] as String),
  ),
  'FreeBusyReportedEvent' => FreeBusyReportedEvent(
    freeBusyBlocks: _decodeFreeBusyBlocks(json['freeBusyBlocks'] as List<Object?>),
    schedulerUserRef: SchedulerUserRef(json['schedulerUserRef'] as String),
  ),
  'CalendarEventCreatedEvent' => CalendarEventCreatedEvent(
    schedulerMeetingRef: SchedulerMeetingRef(json['schedulerMeetingRef'] as String),
    providerEventRef: json['providerEventRef'] as String,
  ),
  'CalendarEventCreationFailedEvent' => CalendarEventCreationFailedEvent(
    failureCode: FailureCode(json['failureCode'] as String),
    schedulerMeetingRef: SchedulerMeetingRef(json['schedulerMeetingRef'] as String),
  ),
  'CalendarEventUpdatedEvent' => CalendarEventUpdatedEvent(
    schedulerMeetingRef: SchedulerMeetingRef(json['schedulerMeetingRef'] as String),
  ),
  'CalendarEventUpdateFailedEvent' => CalendarEventUpdateFailedEvent(
    failureCode: FailureCode(json['failureCode'] as String),
    schedulerMeetingRef: SchedulerMeetingRef(json['schedulerMeetingRef'] as String),
  ),
  'CalendarEventDeletedEvent' => CalendarEventDeletedEvent(
    schedulerMeetingRef: SchedulerMeetingRef(json['schedulerMeetingRef'] as String),
  ),
  'CalendarEventDeletionFailedEvent' => CalendarEventDeletionFailedEvent(
    failureCode: FailureCode(json['failureCode'] as String),
    schedulerMeetingRef: SchedulerMeetingRef(json['schedulerMeetingRef'] as String),
  ),
  'HostSlotFoundFreeEvent' => HostSlotFoundFreeEvent(
    schedulerMeetingRef: SchedulerMeetingRef(json['schedulerMeetingRef'] as String),
  ),
  'HostSlotFoundBusyEvent' => HostSlotFoundBusyEvent(
    schedulerMeetingRef: SchedulerMeetingRef(json['schedulerMeetingRef'] as String),
  ),
  'AvailabilityCheckFailedEvent' => AvailabilityCheckFailedEvent(
    failureCode: FailureCode(json['failureCode'] as String),
    schedulerMeetingRef: SchedulerMeetingRef(json['schedulerMeetingRef'] as String),
  ),
  'CalendarEventMovedDirectlyEvent' => CalendarEventMovedDirectlyEvent(
    schedulerMeetingRef: SchedulerMeetingRef(json['schedulerMeetingRef'] as String),
    movedStart: DateTime.parse(json['movedStart'] as String).toUtc(),
    movedEnd: DateTime.parse(json['movedEnd'] as String).toUtc(),
  ),
  'CalendarEventDeletedDirectlyEvent' => CalendarEventDeletedDirectlyEvent(
    schedulerMeetingRef: SchedulerMeetingRef(json['schedulerMeetingRef'] as String),
  ),
  _ => throw ArgumentError.value(typeName, 'typeName', 'Unknown corporate_calendar event type'),
};

List<JsonMap> _encodeFreeBusyBlocks(FreeBusyBlocks v) => [
  for (final i in v.items)
    <String, Object?>{
      'busyFrom': i.busyFrom.toUtc().toIso8601String(),
      'busyUntil': i.busyUntil.toUtc().toIso8601String(),
    },
];

FreeBusyBlocks _decodeFreeBusyBlocks(List<Object?> json) => FreeBusyBlocks([
  for (final m in json.cast<JsonMap>())
    FreeBusyBlock(
      busyFrom: DateTime.parse(m['busyFrom'] as String).toUtc(),
      busyUntil: DateTime.parse(m['busyUntil'] as String).toUtc(),
    ),
]);
