/// One sample of every `corporate_calendar` event.
library;

import 'package:em_calendly_example/bounded_contexts/corporate_calendar/api.dart';

/// One instance of every `corporate_calendar` event, with HCL example values where they exist.
List<CorporateCalendarEvent> sampleCorporateCalendarEvents() => [
  CalendarAccessGrantedEvent(
    schedulerUserRef: SchedulerUserRef('78b53cf4-6ba0-5597-94e0-b09fef3aa25d'),
    calendarAccount: 'alice@example.com',
  ),
  CalendarAccessFailedEvent(
    failureCode: FailureCode('PROVIDER_UNAVAILABLE'),
    schedulerUserRef: SchedulerUserRef('78b53cf4-6ba0-5597-94e0-b09fef3aa25d'),
  ),
  FreeBusyReportedEvent(
    freeBusyBlocks: FreeBusyBlocks([
      FreeBusyBlock(busyFrom: DateTime.utc(2026, 11, 16, 9), busyUntil: DateTime.utc(2026, 11, 16, 10)),
    ]),
    schedulerUserRef: SchedulerUserRef('78b53cf4-6ba0-5597-94e0-b09fef3aa25d'),
  ),
  CalendarEventCreatedEvent(
    schedulerMeetingRef: SchedulerMeetingRef('f1d91c85-3a90-593b-9d5e-7cb450033766'),
    providerEventRef: 'google:evt-7f3a9c',
  ),
  CalendarEventCreationFailedEvent(
    failureCode: FailureCode('PROVIDER_UNAVAILABLE'),
    schedulerMeetingRef: SchedulerMeetingRef('f1d91c85-3a90-593b-9d5e-7cb450033766'),
  ),
  CalendarEventUpdatedEvent(schedulerMeetingRef: SchedulerMeetingRef('f1d91c85-3a90-593b-9d5e-7cb450033766')),
  CalendarEventUpdateFailedEvent(
    failureCode: FailureCode('PROVIDER_UNAVAILABLE'),
    schedulerMeetingRef: SchedulerMeetingRef('f1d91c85-3a90-593b-9d5e-7cb450033766'),
  ),
  CalendarEventDeletedEvent(schedulerMeetingRef: SchedulerMeetingRef('f1d91c85-3a90-593b-9d5e-7cb450033766')),
  CalendarEventDeletionFailedEvent(
    failureCode: FailureCode('PROVIDER_UNAVAILABLE'),
    schedulerMeetingRef: SchedulerMeetingRef('f1d91c85-3a90-593b-9d5e-7cb450033766'),
  ),
  HostSlotFoundFreeEvent(schedulerMeetingRef: SchedulerMeetingRef('f1d91c85-3a90-593b-9d5e-7cb450033766')),
  HostSlotFoundBusyEvent(schedulerMeetingRef: SchedulerMeetingRef('f1d91c85-3a90-593b-9d5e-7cb450033766')),
  AvailabilityCheckFailedEvent(
    failureCode: FailureCode('PROVIDER_UNAVAILABLE'),
    schedulerMeetingRef: SchedulerMeetingRef('f1d91c85-3a90-593b-9d5e-7cb450033766'),
  ),
  CalendarEventMovedDirectlyEvent(
    schedulerMeetingRef: SchedulerMeetingRef('f1d91c85-3a90-593b-9d5e-7cb450033766'),
    movedStart: DateTime.utc(2026, 11, 18, 10, 0),
    movedEnd: DateTime.utc(2026, 11, 18, 10, 30),
  ),
  CalendarEventDeletedDirectlyEvent(schedulerMeetingRef: SchedulerMeetingRef('f1d91c85-3a90-593b-9d5e-7cb450033766')),
];
