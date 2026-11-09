/// Events of the `corporate_calendar` bounded context.
library;

import '../event_contract.dart';
import 'value_objects.dart';

/// An event of the `corporate_calendar` bounded context.
///
/// The corporate calendar system (external).
sealed class CorporateCalendarEvent implements DomainEvent {
  const CorporateCalendarEvent();
}

/// The `calendar_access_granted` event.
final class CalendarAccessGrantedEvent extends CorporateCalendarEvent {
  const CalendarAccessGrantedEvent({required this.schedulerUserRef, required this.calendarAccount});

  final SchedulerUserRef schedulerUserRef;
  final String calendarAccount;

  @override
  bool operator ==(Object other) =>
      other is CalendarAccessGrantedEvent &&
      other.schedulerUserRef == schedulerUserRef &&
      other.calendarAccount == calendarAccount;

  @override
  int get hashCode => Object.hash(runtimeType, schedulerUserRef, calendarAccount);

  @override
  String toString() =>
      'CalendarAccessGrantedEvent(schedulerUserRef: $schedulerUserRef, calendarAccount: $calendarAccount)';
}

/// The `calendar_access_failed` event.
final class CalendarAccessFailedEvent extends CorporateCalendarEvent {
  const CalendarAccessFailedEvent({required this.failureCode, required this.schedulerUserRef});

  final FailureCode failureCode;
  final SchedulerUserRef schedulerUserRef;

  @override
  bool operator ==(Object other) =>
      other is CalendarAccessFailedEvent &&
      other.failureCode == failureCode &&
      other.schedulerUserRef == schedulerUserRef;

  @override
  int get hashCode => Object.hash(runtimeType, failureCode, schedulerUserRef);

  @override
  String toString() => 'CalendarAccessFailedEvent(failureCode: $failureCode, schedulerUserRef: $schedulerUserRef)';
}

/// The `free_busy_reported` event.
final class FreeBusyReportedEvent extends CorporateCalendarEvent {
  const FreeBusyReportedEvent({required this.freeBusyBlocks, required this.schedulerUserRef});

  final FreeBusyBlocks freeBusyBlocks;
  final SchedulerUserRef schedulerUserRef;

  @override
  bool operator ==(Object other) =>
      other is FreeBusyReportedEvent &&
      other.freeBusyBlocks == freeBusyBlocks &&
      other.schedulerUserRef == schedulerUserRef;

  @override
  int get hashCode => Object.hash(runtimeType, freeBusyBlocks, schedulerUserRef);

  @override
  String toString() => 'FreeBusyReportedEvent(freeBusyBlocks: $freeBusyBlocks, schedulerUserRef: $schedulerUserRef)';
}

/// The `calendar_event_created` event.
final class CalendarEventCreatedEvent extends CorporateCalendarEvent {
  const CalendarEventCreatedEvent({required this.schedulerMeetingRef, required this.providerEventRef});

  final SchedulerMeetingRef schedulerMeetingRef;
  final String providerEventRef;

  @override
  bool operator ==(Object other) =>
      other is CalendarEventCreatedEvent &&
      other.schedulerMeetingRef == schedulerMeetingRef &&
      other.providerEventRef == providerEventRef;

  @override
  int get hashCode => Object.hash(runtimeType, schedulerMeetingRef, providerEventRef);

  @override
  String toString() =>
      'CalendarEventCreatedEvent(schedulerMeetingRef: $schedulerMeetingRef, providerEventRef: $providerEventRef)';
}

/// The `calendar_event_creation_failed` event.
final class CalendarEventCreationFailedEvent extends CorporateCalendarEvent {
  const CalendarEventCreationFailedEvent({required this.failureCode, required this.schedulerMeetingRef});

  final FailureCode failureCode;
  final SchedulerMeetingRef schedulerMeetingRef;

  @override
  bool operator ==(Object other) =>
      other is CalendarEventCreationFailedEvent &&
      other.failureCode == failureCode &&
      other.schedulerMeetingRef == schedulerMeetingRef;

  @override
  int get hashCode => Object.hash(runtimeType, failureCode, schedulerMeetingRef);

  @override
  String toString() =>
      'CalendarEventCreationFailedEvent(failureCode: $failureCode, schedulerMeetingRef: $schedulerMeetingRef)';
}

/// The `calendar_event_updated` event.
final class CalendarEventUpdatedEvent extends CorporateCalendarEvent {
  const CalendarEventUpdatedEvent({required this.schedulerMeetingRef});

  final SchedulerMeetingRef schedulerMeetingRef;

  @override
  bool operator ==(Object other) =>
      other is CalendarEventUpdatedEvent && other.schedulerMeetingRef == schedulerMeetingRef;

  @override
  int get hashCode => Object.hash(runtimeType, schedulerMeetingRef);

  @override
  String toString() => 'CalendarEventUpdatedEvent(schedulerMeetingRef: $schedulerMeetingRef)';
}

/// The `calendar_event_update_failed` event.
final class CalendarEventUpdateFailedEvent extends CorporateCalendarEvent {
  const CalendarEventUpdateFailedEvent({required this.failureCode, required this.schedulerMeetingRef});

  final FailureCode failureCode;
  final SchedulerMeetingRef schedulerMeetingRef;

  @override
  bool operator ==(Object other) =>
      other is CalendarEventUpdateFailedEvent &&
      other.failureCode == failureCode &&
      other.schedulerMeetingRef == schedulerMeetingRef;

  @override
  int get hashCode => Object.hash(runtimeType, failureCode, schedulerMeetingRef);

  @override
  String toString() =>
      'CalendarEventUpdateFailedEvent(failureCode: $failureCode, schedulerMeetingRef: $schedulerMeetingRef)';
}

/// The `calendar_event_deleted` event.
final class CalendarEventDeletedEvent extends CorporateCalendarEvent {
  const CalendarEventDeletedEvent({required this.schedulerMeetingRef});

  final SchedulerMeetingRef schedulerMeetingRef;

  @override
  bool operator ==(Object other) =>
      other is CalendarEventDeletedEvent && other.schedulerMeetingRef == schedulerMeetingRef;

  @override
  int get hashCode => Object.hash(runtimeType, schedulerMeetingRef);

  @override
  String toString() => 'CalendarEventDeletedEvent(schedulerMeetingRef: $schedulerMeetingRef)';
}

/// The `calendar_event_deletion_failed` event.
final class CalendarEventDeletionFailedEvent extends CorporateCalendarEvent {
  const CalendarEventDeletionFailedEvent({required this.failureCode, required this.schedulerMeetingRef});

  final FailureCode failureCode;
  final SchedulerMeetingRef schedulerMeetingRef;

  @override
  bool operator ==(Object other) =>
      other is CalendarEventDeletionFailedEvent &&
      other.failureCode == failureCode &&
      other.schedulerMeetingRef == schedulerMeetingRef;

  @override
  int get hashCode => Object.hash(runtimeType, failureCode, schedulerMeetingRef);

  @override
  String toString() =>
      'CalendarEventDeletionFailedEvent(failureCode: $failureCode, schedulerMeetingRef: $schedulerMeetingRef)';
}

/// The live free/busy answer: the host is free for the asked time. Holds no calendar content.
final class HostSlotFoundFreeEvent extends CorporateCalendarEvent {
  const HostSlotFoundFreeEvent({required this.schedulerMeetingRef});

  final SchedulerMeetingRef schedulerMeetingRef;

  @override
  bool operator ==(Object other) => other is HostSlotFoundFreeEvent && other.schedulerMeetingRef == schedulerMeetingRef;

  @override
  int get hashCode => Object.hash(runtimeType, schedulerMeetingRef);

  @override
  String toString() => 'HostSlotFoundFreeEvent(schedulerMeetingRef: $schedulerMeetingRef)';
}

/// The live free/busy answer: the host is busy for the asked time. Holds no calendar content.
final class HostSlotFoundBusyEvent extends CorporateCalendarEvent {
  const HostSlotFoundBusyEvent({required this.schedulerMeetingRef});

  final SchedulerMeetingRef schedulerMeetingRef;

  @override
  bool operator ==(Object other) => other is HostSlotFoundBusyEvent && other.schedulerMeetingRef == schedulerMeetingRef;

  @override
  int get hashCode => Object.hash(runtimeType, schedulerMeetingRef);

  @override
  String toString() => 'HostSlotFoundBusyEvent(schedulerMeetingRef: $schedulerMeetingRef)';
}

/// The calendar system could not answer the live free/busy question.
final class AvailabilityCheckFailedEvent extends CorporateCalendarEvent {
  const AvailabilityCheckFailedEvent({required this.failureCode, required this.schedulerMeetingRef});

  final FailureCode failureCode;
  final SchedulerMeetingRef schedulerMeetingRef;

  @override
  bool operator ==(Object other) =>
      other is AvailabilityCheckFailedEvent &&
      other.failureCode == failureCode &&
      other.schedulerMeetingRef == schedulerMeetingRef;

  @override
  int get hashCode => Object.hash(runtimeType, failureCode, schedulerMeetingRef);

  @override
  String toString() =>
      'AvailabilityCheckFailedEvent(failureCode: $failureCode, schedulerMeetingRef: $schedulerMeetingRef)';
}

/// Someone moved the meeting's event on the host's calendar, outside the scheduler. Holds the new times only.
final class CalendarEventMovedDirectlyEvent extends CorporateCalendarEvent {
  const CalendarEventMovedDirectlyEvent({
    required this.schedulerMeetingRef,
    required this.movedStart,
    required this.movedEnd,
  });

  final SchedulerMeetingRef schedulerMeetingRef;
  final DateTime movedStart;
  final DateTime movedEnd;

  @override
  bool operator ==(Object other) =>
      other is CalendarEventMovedDirectlyEvent &&
      other.schedulerMeetingRef == schedulerMeetingRef &&
      other.movedStart == movedStart &&
      other.movedEnd == movedEnd;

  @override
  int get hashCode => Object.hash(runtimeType, schedulerMeetingRef, movedStart, movedEnd);

  @override
  String toString() =>
      'CalendarEventMovedDirectlyEvent(schedulerMeetingRef: $schedulerMeetingRef, movedStart: $movedStart, movedEnd: $movedEnd)';
}

/// Someone deleted the meeting's event from the host's calendar, outside the scheduler.
final class CalendarEventDeletedDirectlyEvent extends CorporateCalendarEvent {
  const CalendarEventDeletedDirectlyEvent({required this.schedulerMeetingRef});

  final SchedulerMeetingRef schedulerMeetingRef;

  @override
  bool operator ==(Object other) =>
      other is CalendarEventDeletedDirectlyEvent && other.schedulerMeetingRef == schedulerMeetingRef;

  @override
  int get hashCode => Object.hash(runtimeType, schedulerMeetingRef);

  @override
  String toString() => 'CalendarEventDeletedDirectlyEvent(schedulerMeetingRef: $schedulerMeetingRef)';
}
