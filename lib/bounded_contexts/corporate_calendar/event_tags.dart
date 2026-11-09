/// Type names, tags, and streams of the `corporate_calendar` events.
library;

import '../event_contract.dart';
import 'events.dart';

/// The stable type name of [e]: its Dart class name.
String corporateCalendarEventTypeName(CorporateCalendarEvent e) => switch (e) {
  CalendarAccessGrantedEvent() => 'CalendarAccessGrantedEvent',
  CalendarAccessFailedEvent() => 'CalendarAccessFailedEvent',
  FreeBusyReportedEvent() => 'FreeBusyReportedEvent',
  CalendarEventCreatedEvent() => 'CalendarEventCreatedEvent',
  CalendarEventCreationFailedEvent() => 'CalendarEventCreationFailedEvent',
  CalendarEventUpdatedEvent() => 'CalendarEventUpdatedEvent',
  CalendarEventUpdateFailedEvent() => 'CalendarEventUpdateFailedEvent',
  CalendarEventDeletedEvent() => 'CalendarEventDeletedEvent',
  CalendarEventDeletionFailedEvent() => 'CalendarEventDeletionFailedEvent',
  HostSlotFoundFreeEvent() => 'HostSlotFoundFreeEvent',
  HostSlotFoundBusyEvent() => 'HostSlotFoundBusyEvent',
  AvailabilityCheckFailedEvent() => 'AvailabilityCheckFailedEvent',
  CalendarEventMovedDirectlyEvent() => 'CalendarEventMovedDirectlyEvent',
  CalendarEventDeletedDirectlyEvent() => 'CalendarEventDeletedDirectlyEvent',
};

/// The tags of [e]: identity fields, correlation keys, and deduplication keys.
List<EventTag> corporateCalendarEventTags(CorporateCalendarEvent e) => switch (e) {
  final CalendarAccessGrantedEvent e => [(tag: 'schedulerUserRef', value: e.schedulerUserRef.value)],
  final CalendarAccessFailedEvent e => [(tag: 'schedulerUserRef', value: e.schedulerUserRef.value)],
  final FreeBusyReportedEvent e => [(tag: 'schedulerUserRef', value: e.schedulerUserRef.value)],
  final CalendarEventCreatedEvent e => [
    (tag: 'schedulerMeetingRef', value: e.schedulerMeetingRef.value),
    (tag: 'providerEventRef', value: e.providerEventRef),
  ],
  final CalendarEventCreationFailedEvent e => [(tag: 'schedulerMeetingRef', value: e.schedulerMeetingRef.value)],
  final CalendarEventUpdatedEvent e => [(tag: 'schedulerMeetingRef', value: e.schedulerMeetingRef.value)],
  final CalendarEventUpdateFailedEvent e => [(tag: 'schedulerMeetingRef', value: e.schedulerMeetingRef.value)],
  final CalendarEventDeletedEvent e => [(tag: 'schedulerMeetingRef', value: e.schedulerMeetingRef.value)],
  final CalendarEventDeletionFailedEvent e => [(tag: 'schedulerMeetingRef', value: e.schedulerMeetingRef.value)],
  final HostSlotFoundFreeEvent e => [(tag: 'schedulerMeetingRef', value: e.schedulerMeetingRef.value)],
  final HostSlotFoundBusyEvent e => [(tag: 'schedulerMeetingRef', value: e.schedulerMeetingRef.value)],
  final AvailabilityCheckFailedEvent e => [(tag: 'schedulerMeetingRef', value: e.schedulerMeetingRef.value)],
  final CalendarEventMovedDirectlyEvent e => [(tag: 'schedulerMeetingRef', value: e.schedulerMeetingRef.value)],
  final CalendarEventDeletedDirectlyEvent e => [(tag: 'schedulerMeetingRef', value: e.schedulerMeetingRef.value)],
};

/// The fstore-sql stream of [e].
EventStream corporateCalendarEventStream(CorporateCalendarEvent e) => switch (e) {
  final CalendarAccessGrantedEvent e => (type: 'corporate_calendar', id: e.schedulerUserRef.value),
  final CalendarAccessFailedEvent e => (type: 'corporate_calendar', id: e.schedulerUserRef.value),
  final FreeBusyReportedEvent e => (type: 'corporate_calendar', id: e.schedulerUserRef.value),
  final CalendarEventCreatedEvent e => (type: 'corporate_calendar', id: e.schedulerMeetingRef.value),
  final CalendarEventCreationFailedEvent e => (type: 'corporate_calendar', id: e.schedulerMeetingRef.value),
  final CalendarEventUpdatedEvent e => (type: 'corporate_calendar', id: e.schedulerMeetingRef.value),
  final CalendarEventUpdateFailedEvent e => (type: 'corporate_calendar', id: e.schedulerMeetingRef.value),
  final CalendarEventDeletedEvent e => (type: 'corporate_calendar', id: e.schedulerMeetingRef.value),
  final CalendarEventDeletionFailedEvent e => (type: 'corporate_calendar', id: e.schedulerMeetingRef.value),
  final HostSlotFoundFreeEvent e => (type: 'corporate_calendar', id: e.schedulerMeetingRef.value),
  final HostSlotFoundBusyEvent e => (type: 'corporate_calendar', id: e.schedulerMeetingRef.value),
  final AvailabilityCheckFailedEvent e => (type: 'corporate_calendar', id: e.schedulerMeetingRef.value),
  final CalendarEventMovedDirectlyEvent e => (type: 'corporate_calendar', id: e.schedulerMeetingRef.value),
  final CalendarEventDeletedDirectlyEvent e => (type: 'corporate_calendar', id: e.schedulerMeetingRef.value),
};
