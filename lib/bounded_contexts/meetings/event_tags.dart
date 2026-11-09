/// Type names, tags, and streams of the `meetings` events.
library;

import '../event_contract.dart';
import 'events.dart';

/// The stable type name of [e]: its Dart class name.
String meetingsEventTypeName(MeetingsEvent e) => switch (e) {
  MeetingSlotReservedEvent() => 'MeetingSlotReservedEvent',
  BookingAvailabilityCheckRequestedEvent() => 'BookingAvailabilityCheckRequestedEvent',
  BookingSlotVerifiedEvent() => 'BookingSlotVerifiedEvent',
  CalendarEventRequestedEvent() => 'CalendarEventRequestedEvent',
  MeetingConfirmedEvent() => 'MeetingConfirmedEvent',
  MeetingBookingFailedEvent() => 'MeetingBookingFailedEvent',
  BookingConfirmationSentEvent() => 'BookingConfirmationSentEvent',
  MeetingRescheduleRequestedEvent() => 'MeetingRescheduleRequestedEvent',
  RescheduleAvailabilityCheckRequestedEvent() => 'RescheduleAvailabilityCheckRequestedEvent',
  NewSlotVerifiedEvent() => 'NewSlotVerifiedEvent',
  CalendarEventUpdateRequestedEvent() => 'CalendarEventUpdateRequestedEvent',
  MeetingRescheduledEvent() => 'MeetingRescheduledEvent',
  MeetingMovedInCalendarEvent() => 'MeetingMovedInCalendarEvent',
  MeetingRescheduleFailedEvent() => 'MeetingRescheduleFailedEvent',
  RescheduleNoticeSentEvent() => 'RescheduleNoticeSentEvent',
  MeetingCancellationRequestedEvent() => 'MeetingCancellationRequestedEvent',
  CalendarEventDeletionRequestedEvent() => 'CalendarEventDeletionRequestedEvent',
  MeetingCanceledEvent() => 'MeetingCanceledEvent',
  MeetingCancellationFailedEvent() => 'MeetingCancellationFailedEvent',
  CancellationNoticeSentEvent() => 'CancellationNoticeSentEvent',
  MeetingCompletedEvent() => 'MeetingCompletedEvent',
};

/// The tags of [e]: identity fields, correlation keys, and deduplication keys.
List<EventTag> meetingsEventTags(MeetingsEvent e) => switch (e) {
  final MeetingSlotReservedEvent e => [
    (tag: 'meetingId', value: e.meetingId.value),
    (tag: 'hostId', value: e.hostId.value),
    (tag: 'bookerId', value: e.bookerId.value),
    (tag: 'meetingTypeId', value: e.meetingTypeId.value),
  ],
  final BookingAvailabilityCheckRequestedEvent e => [
    (tag: 'meetingId', value: e.meetingId.value),
    (tag: 'hostId', value: e.hostId.value),
  ],
  final BookingSlotVerifiedEvent e => [(tag: 'meetingId', value: e.meetingId.value)],
  final CalendarEventRequestedEvent e => [(tag: 'meetingId', value: e.meetingId.value)],
  final MeetingConfirmedEvent e => [(tag: 'meetingId', value: e.meetingId.value)],
  final MeetingBookingFailedEvent e => [(tag: 'meetingId', value: e.meetingId.value)],
  final BookingConfirmationSentEvent e => [(tag: 'meetingId', value: e.meetingId.value)],
  final MeetingRescheduleRequestedEvent e => [
    (tag: 'meetingId', value: e.meetingId.value),
    (tag: 'hostId', value: e.hostId.value),
  ],
  final RescheduleAvailabilityCheckRequestedEvent e => [
    (tag: 'meetingId', value: e.meetingId.value),
    (tag: 'hostId', value: e.hostId.value),
  ],
  final NewSlotVerifiedEvent e => [(tag: 'meetingId', value: e.meetingId.value)],
  final CalendarEventUpdateRequestedEvent e => [(tag: 'meetingId', value: e.meetingId.value)],
  final MeetingRescheduledEvent e => [(tag: 'meetingId', value: e.meetingId.value)],
  final MeetingMovedInCalendarEvent e => [(tag: 'meetingId', value: e.meetingId.value)],
  final MeetingRescheduleFailedEvent e => [(tag: 'meetingId', value: e.meetingId.value)],
  final RescheduleNoticeSentEvent e => [(tag: 'meetingId', value: e.meetingId.value)],
  final MeetingCancellationRequestedEvent e => [
    (tag: 'meetingId', value: e.meetingId.value),
    (tag: 'hostId', value: e.hostId.value),
  ],
  final CalendarEventDeletionRequestedEvent e => [(tag: 'meetingId', value: e.meetingId.value)],
  final MeetingCanceledEvent e => [(tag: 'meetingId', value: e.meetingId.value)],
  final MeetingCancellationFailedEvent e => [(tag: 'meetingId', value: e.meetingId.value)],
  final CancellationNoticeSentEvent e => [(tag: 'meetingId', value: e.meetingId.value)],
  final MeetingCompletedEvent e => [(tag: 'meetingId', value: e.meetingId.value)],
};

/// The fstore-sql stream of [e].
EventStream meetingsEventStream(MeetingsEvent e) => switch (e) {
  final MeetingSlotReservedEvent e => (type: 'meeting', id: e.meetingId.value),
  final BookingAvailabilityCheckRequestedEvent e => (type: 'meeting', id: e.meetingId.value),
  final BookingSlotVerifiedEvent e => (type: 'meeting', id: e.meetingId.value),
  final CalendarEventRequestedEvent e => (type: 'meeting', id: e.meetingId.value),
  final MeetingConfirmedEvent e => (type: 'meeting', id: e.meetingId.value),
  final MeetingBookingFailedEvent e => (type: 'meeting', id: e.meetingId.value),
  final BookingConfirmationSentEvent e => (type: 'meeting', id: e.meetingId.value),
  final MeetingRescheduleRequestedEvent e => (type: 'meeting', id: e.meetingId.value),
  final RescheduleAvailabilityCheckRequestedEvent e => (type: 'meeting', id: e.meetingId.value),
  final NewSlotVerifiedEvent e => (type: 'meeting', id: e.meetingId.value),
  final CalendarEventUpdateRequestedEvent e => (type: 'meeting', id: e.meetingId.value),
  final MeetingRescheduledEvent e => (type: 'meeting', id: e.meetingId.value),
  final MeetingMovedInCalendarEvent e => (type: 'meeting', id: e.meetingId.value),
  final MeetingRescheduleFailedEvent e => (type: 'meeting', id: e.meetingId.value),
  final RescheduleNoticeSentEvent e => (type: 'meeting', id: e.meetingId.value),
  final MeetingCancellationRequestedEvent e => (type: 'meeting', id: e.meetingId.value),
  final CalendarEventDeletionRequestedEvent e => (type: 'meeting', id: e.meetingId.value),
  final MeetingCanceledEvent e => (type: 'meeting', id: e.meetingId.value),
  final MeetingCancellationFailedEvent e => (type: 'meeting', id: e.meetingId.value),
  final CancellationNoticeSentEvent e => (type: 'meeting', id: e.meetingId.value),
  final MeetingCompletedEvent e => (type: 'meeting', id: e.meetingId.value),
};
