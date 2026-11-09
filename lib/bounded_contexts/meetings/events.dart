/// Events of the `meetings` bounded context.
library;

import '../event_contract.dart';
import '../host_setup/value_objects.dart';
import 'value_objects.dart';

/// An event of the `meetings` bounded context.
///
/// Booked one-on-one meetings, from reservation to their end.
sealed class MeetingsEvent implements DomainEvent {
  const MeetingsEvent();
}

/// The meeting record exists and its slot is held. The calendar event does not exist yet.
///
/// Aggregate: `meeting`.
final class MeetingSlotReservedEvent extends MeetingsEvent {
  const MeetingSlotReservedEvent({
    required this.meetingId,
    required this.hostId,
    required this.bookerId,
    required this.meetingTypeId,
    required this.meetingTitle,
    required this.meetingLocation,
    required this.slotStart,
    required this.slotEnd,
    required this.participants,
  });

  final MeetingId meetingId;
  final HostId hostId;
  final BookerId bookerId;
  final MeetingTypeId meetingTypeId;
  final MeetingTitle meetingTitle;
  final MeetingLocation meetingLocation;
  final SlotStart slotStart;
  final SlotEnd slotEnd;
  final Participants participants;

  @override
  bool operator ==(Object other) =>
      other is MeetingSlotReservedEvent &&
      other.meetingId == meetingId &&
      other.hostId == hostId &&
      other.bookerId == bookerId &&
      other.meetingTypeId == meetingTypeId &&
      other.meetingTitle == meetingTitle &&
      other.meetingLocation == meetingLocation &&
      other.slotStart == slotStart &&
      other.slotEnd == slotEnd &&
      other.participants == participants;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    meetingId,
    hostId,
    bookerId,
    meetingTypeId,
    meetingTitle,
    meetingLocation,
    slotStart,
    slotEnd,
    participants,
  );

  @override
  String toString() =>
      'MeetingSlotReservedEvent(meetingId: $meetingId, hostId: $hostId, bookerId: $bookerId, meetingTypeId: $meetingTypeId, meetingTitle: $meetingTitle, meetingLocation: $meetingLocation, slotStart: $slotStart, slotEnd: $slotEnd, participants: $participants)';
}

/// The live free/busy question for the held slot. It asks for free/busy data only.
///
/// Aggregate: `meeting`.
final class BookingAvailabilityCheckRequestedEvent extends MeetingsEvent {
  const BookingAvailabilityCheckRequestedEvent({
    required this.meetingId,
    required this.hostId,
    required this.slotStart,
    required this.slotEnd,
  });

  final MeetingId meetingId;
  final HostId hostId;
  final SlotStart slotStart;
  final SlotEnd slotEnd;

  @override
  bool operator ==(Object other) =>
      other is BookingAvailabilityCheckRequestedEvent &&
      other.meetingId == meetingId &&
      other.hostId == hostId &&
      other.slotStart == slotStart &&
      other.slotEnd == slotEnd;

  @override
  int get hashCode => Object.hash(runtimeType, meetingId, hostId, slotStart, slotEnd);

  @override
  String toString() =>
      'BookingAvailabilityCheckRequestedEvent(meetingId: $meetingId, hostId: $hostId, slotStart: $slotStart, slotEnd: $slotEnd)';
}

/// The calendar system has confirmed that the host is free for the held slot.
///
/// Aggregate: `meeting`.
final class BookingSlotVerifiedEvent extends MeetingsEvent {
  const BookingSlotVerifiedEvent({required this.meetingId});

  final MeetingId meetingId;

  @override
  bool operator ==(Object other) => other is BookingSlotVerifiedEvent && other.meetingId == meetingId;

  @override
  int get hashCode => Object.hash(runtimeType, meetingId);

  @override
  String toString() => 'BookingSlotVerifiedEvent(meetingId: $meetingId)';
}

/// The `calendar_event_requested` event.
///
/// Aggregate: `meeting`.
final class CalendarEventRequestedEvent extends MeetingsEvent {
  const CalendarEventRequestedEvent({required this.meetingId});

  final MeetingId meetingId;

  @override
  bool operator ==(Object other) => other is CalendarEventRequestedEvent && other.meetingId == meetingId;

  @override
  int get hashCode => Object.hash(runtimeType, meetingId);

  @override
  String toString() => 'CalendarEventRequestedEvent(meetingId: $meetingId)';
}

/// The `meeting_confirmed` event.
///
/// Aggregate: `meeting`.
final class MeetingConfirmedEvent extends MeetingsEvent {
  const MeetingConfirmedEvent({required this.meetingId, required this.calendarEventId});

  final MeetingId meetingId;
  final CalendarEventId calendarEventId;

  @override
  bool operator ==(Object other) =>
      other is MeetingConfirmedEvent && other.meetingId == meetingId && other.calendarEventId == calendarEventId;

  @override
  int get hashCode => Object.hash(runtimeType, meetingId, calendarEventId);

  @override
  String toString() => 'MeetingConfirmedEvent(meetingId: $meetingId, calendarEventId: $calendarEventId)';
}

/// The held slot is released.
///
/// Aggregate: `meeting`.
final class MeetingBookingFailedEvent extends MeetingsEvent {
  const MeetingBookingFailedEvent({required this.meetingId, required this.failureReason});

  final MeetingId meetingId;
  final FailureReason failureReason;

  @override
  bool operator ==(Object other) =>
      other is MeetingBookingFailedEvent && other.meetingId == meetingId && other.failureReason == failureReason;

  @override
  int get hashCode => Object.hash(runtimeType, meetingId, failureReason);

  @override
  String toString() => 'MeetingBookingFailedEvent(meetingId: $meetingId, failureReason: $failureReason)';
}

/// The `booking_confirmation_sent` event.
///
/// Aggregate: `meeting`.
final class BookingConfirmationSentEvent extends MeetingsEvent {
  const BookingConfirmationSentEvent({required this.meetingId, required this.participants});

  final MeetingId meetingId;
  final Participants participants;

  @override
  bool operator ==(Object other) =>
      other is BookingConfirmationSentEvent && other.meetingId == meetingId && other.participants == participants;

  @override
  int get hashCode => Object.hash(runtimeType, meetingId, participants);

  @override
  String toString() => 'BookingConfirmationSentEvent(meetingId: $meetingId, participants: $participants)';
}

/// The new slot is held as well. The original slot stays held until the calendar accepts the change.
///
/// Aggregate: `meeting`.
final class MeetingRescheduleRequestedEvent extends MeetingsEvent {
  const MeetingRescheduleRequestedEvent({
    required this.meetingId,
    required this.hostId,
    required this.requestedBy,
    required this.newSlotStart,
    required this.newSlotEnd,
    required this.calendarEventId,
    required this.participants,
  });

  final MeetingId meetingId;
  final HostId hostId;
  final RequestedBy requestedBy;
  final NewSlotStart newSlotStart;
  final NewSlotEnd newSlotEnd;
  final CalendarEventId calendarEventId;
  final Participants participants;

  @override
  bool operator ==(Object other) =>
      other is MeetingRescheduleRequestedEvent &&
      other.meetingId == meetingId &&
      other.hostId == hostId &&
      other.requestedBy == requestedBy &&
      other.newSlotStart == newSlotStart &&
      other.newSlotEnd == newSlotEnd &&
      other.calendarEventId == calendarEventId &&
      other.participants == participants;

  @override
  int get hashCode =>
      Object.hash(runtimeType, meetingId, hostId, requestedBy, newSlotStart, newSlotEnd, calendarEventId, participants);

  @override
  String toString() =>
      'MeetingRescheduleRequestedEvent(meetingId: $meetingId, hostId: $hostId, requestedBy: $requestedBy, newSlotStart: $newSlotStart, newSlotEnd: $newSlotEnd, calendarEventId: $calendarEventId, participants: $participants)';
}

/// The live free/busy question for the new slot. It asks for free/busy data only.
///
/// Aggregate: `meeting`.
final class RescheduleAvailabilityCheckRequestedEvent extends MeetingsEvent {
  const RescheduleAvailabilityCheckRequestedEvent({
    required this.meetingId,
    required this.hostId,
    required this.newSlotStart,
    required this.newSlotEnd,
  });

  final MeetingId meetingId;
  final HostId hostId;
  final NewSlotStart newSlotStart;
  final NewSlotEnd newSlotEnd;

  @override
  bool operator ==(Object other) =>
      other is RescheduleAvailabilityCheckRequestedEvent &&
      other.meetingId == meetingId &&
      other.hostId == hostId &&
      other.newSlotStart == newSlotStart &&
      other.newSlotEnd == newSlotEnd;

  @override
  int get hashCode => Object.hash(runtimeType, meetingId, hostId, newSlotStart, newSlotEnd);

  @override
  String toString() =>
      'RescheduleAvailabilityCheckRequestedEvent(meetingId: $meetingId, hostId: $hostId, newSlotStart: $newSlotStart, newSlotEnd: $newSlotEnd)';
}

/// The calendar system has confirmed that the host is free for the new slot.
///
/// Aggregate: `meeting`.
final class NewSlotVerifiedEvent extends MeetingsEvent {
  const NewSlotVerifiedEvent({required this.meetingId});

  final MeetingId meetingId;

  @override
  bool operator ==(Object other) => other is NewSlotVerifiedEvent && other.meetingId == meetingId;

  @override
  int get hashCode => Object.hash(runtimeType, meetingId);

  @override
  String toString() => 'NewSlotVerifiedEvent(meetingId: $meetingId)';
}

/// The `calendar_event_update_requested` event.
///
/// Aggregate: `meeting`.
final class CalendarEventUpdateRequestedEvent extends MeetingsEvent {
  const CalendarEventUpdateRequestedEvent({required this.meetingId, required this.newSlotStart});

  final MeetingId meetingId;
  final NewSlotStart newSlotStart;

  @override
  bool operator ==(Object other) =>
      other is CalendarEventUpdateRequestedEvent && other.meetingId == meetingId && other.newSlotStart == newSlotStart;

  @override
  int get hashCode => Object.hash(runtimeType, meetingId, newSlotStart);

  @override
  String toString() => 'CalendarEventUpdateRequestedEvent(meetingId: $meetingId, newSlotStart: $newSlotStart)';
}

/// The new slot becomes the meeting time and the original slot is released.
///
/// Aggregate: `meeting`.
final class MeetingRescheduledEvent extends MeetingsEvent {
  const MeetingRescheduledEvent({required this.meetingId});

  final MeetingId meetingId;

  @override
  bool operator ==(Object other) => other is MeetingRescheduledEvent && other.meetingId == meetingId;

  @override
  int get hashCode => Object.hash(runtimeType, meetingId);

  @override
  String toString() => 'MeetingRescheduledEvent(meetingId: $meetingId)';
}

/// The meeting's event was moved directly in the calendar, and the meeting takes that time. Any other slot that the meeting held is released.
///
/// Aggregate: `meeting`.
final class MeetingMovedInCalendarEvent extends MeetingsEvent {
  const MeetingMovedInCalendarEvent({required this.meetingId, required this.newSlotStart, required this.newSlotEnd});

  final MeetingId meetingId;
  final NewSlotStart newSlotStart;
  final NewSlotEnd newSlotEnd;

  @override
  bool operator ==(Object other) =>
      other is MeetingMovedInCalendarEvent &&
      other.meetingId == meetingId &&
      other.newSlotStart == newSlotStart &&
      other.newSlotEnd == newSlotEnd;

  @override
  int get hashCode => Object.hash(runtimeType, meetingId, newSlotStart, newSlotEnd);

  @override
  String toString() =>
      'MeetingMovedInCalendarEvent(meetingId: $meetingId, newSlotStart: $newSlotStart, newSlotEnd: $newSlotEnd)';
}

/// The new slot is released and the meeting keeps its original time.
///
/// Aggregate: `meeting`.
final class MeetingRescheduleFailedEvent extends MeetingsEvent {
  const MeetingRescheduleFailedEvent({required this.meetingId, required this.failureReason});

  final MeetingId meetingId;
  final FailureReason failureReason;

  @override
  bool operator ==(Object other) =>
      other is MeetingRescheduleFailedEvent && other.meetingId == meetingId && other.failureReason == failureReason;

  @override
  int get hashCode => Object.hash(runtimeType, meetingId, failureReason);

  @override
  String toString() => 'MeetingRescheduleFailedEvent(meetingId: $meetingId, failureReason: $failureReason)';
}

/// The `reschedule_notice_sent` event.
///
/// Aggregate: `meeting`.
final class RescheduleNoticeSentEvent extends MeetingsEvent {
  const RescheduleNoticeSentEvent({required this.meetingId, required this.newSlotStart, required this.participants});

  final MeetingId meetingId;
  final NewSlotStart newSlotStart;
  final Participants participants;

  @override
  bool operator ==(Object other) =>
      other is RescheduleNoticeSentEvent &&
      other.meetingId == meetingId &&
      other.newSlotStart == newSlotStart &&
      other.participants == participants;

  @override
  int get hashCode => Object.hash(runtimeType, meetingId, newSlotStart, participants);

  @override
  String toString() =>
      'RescheduleNoticeSentEvent(meetingId: $meetingId, newSlotStart: $newSlotStart, participants: $participants)';
}

/// The `meeting_cancellation_requested` event.
///
/// Aggregate: `meeting`.
final class MeetingCancellationRequestedEvent extends MeetingsEvent {
  const MeetingCancellationRequestedEvent({
    required this.meetingId,
    required this.hostId,
    required this.requestedBy,
    required this.calendarEventId,
    required this.participants,
  });

  final MeetingId meetingId;
  final HostId hostId;
  final RequestedBy requestedBy;
  final CalendarEventId calendarEventId;
  final Participants participants;

  @override
  bool operator ==(Object other) =>
      other is MeetingCancellationRequestedEvent &&
      other.meetingId == meetingId &&
      other.hostId == hostId &&
      other.requestedBy == requestedBy &&
      other.calendarEventId == calendarEventId &&
      other.participants == participants;

  @override
  int get hashCode => Object.hash(runtimeType, meetingId, hostId, requestedBy, calendarEventId, participants);

  @override
  String toString() =>
      'MeetingCancellationRequestedEvent(meetingId: $meetingId, hostId: $hostId, requestedBy: $requestedBy, calendarEventId: $calendarEventId, participants: $participants)';
}

/// The `calendar_event_deletion_requested` event.
///
/// Aggregate: `meeting`.
final class CalendarEventDeletionRequestedEvent extends MeetingsEvent {
  const CalendarEventDeletionRequestedEvent({required this.meetingId});

  final MeetingId meetingId;

  @override
  bool operator ==(Object other) => other is CalendarEventDeletionRequestedEvent && other.meetingId == meetingId;

  @override
  int get hashCode => Object.hash(runtimeType, meetingId);

  @override
  String toString() => 'CalendarEventDeletionRequestedEvent(meetingId: $meetingId)';
}

/// Every slot that the meeting held is released. The cancellation came from the scheduler or from a direct deletion in the calendar.
///
/// Aggregate: `meeting`.
final class MeetingCanceledEvent extends MeetingsEvent {
  const MeetingCanceledEvent({required this.meetingId});

  final MeetingId meetingId;

  @override
  bool operator ==(Object other) => other is MeetingCanceledEvent && other.meetingId == meetingId;

  @override
  int get hashCode => Object.hash(runtimeType, meetingId);

  @override
  String toString() => 'MeetingCanceledEvent(meetingId: $meetingId)';
}

/// The meeting stays confirmed.
///
/// Aggregate: `meeting`.
final class MeetingCancellationFailedEvent extends MeetingsEvent {
  const MeetingCancellationFailedEvent({required this.meetingId, required this.failureReason});

  final MeetingId meetingId;
  final FailureReason failureReason;

  @override
  bool operator ==(Object other) =>
      other is MeetingCancellationFailedEvent && other.meetingId == meetingId && other.failureReason == failureReason;

  @override
  int get hashCode => Object.hash(runtimeType, meetingId, failureReason);

  @override
  String toString() => 'MeetingCancellationFailedEvent(meetingId: $meetingId, failureReason: $failureReason)';
}

/// The `cancellation_notice_sent` event.
///
/// Aggregate: `meeting`.
final class CancellationNoticeSentEvent extends MeetingsEvent {
  const CancellationNoticeSentEvent({required this.meetingId, required this.participants});

  final MeetingId meetingId;
  final Participants participants;

  @override
  bool operator ==(Object other) =>
      other is CancellationNoticeSentEvent && other.meetingId == meetingId && other.participants == participants;

  @override
  int get hashCode => Object.hash(runtimeType, meetingId, participants);

  @override
  String toString() => 'CancellationNoticeSentEvent(meetingId: $meetingId, participants: $participants)';
}

/// The `meeting_completed` event.
///
/// Aggregate: `meeting`.
final class MeetingCompletedEvent extends MeetingsEvent {
  const MeetingCompletedEvent({required this.meetingId});

  final MeetingId meetingId;

  @override
  bool operator ==(Object other) => other is MeetingCompletedEvent && other.meetingId == meetingId;

  @override
  int get hashCode => Object.hash(runtimeType, meetingId);

  @override
  String toString() => 'MeetingCompletedEvent(meetingId: $meetingId)';
}
