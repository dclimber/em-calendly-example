/// JSON codec and event contract of the `meetings` bounded context.
library;

import '../event_contract.dart';
import 'event_tags.dart';
import 'events.dart';
import '../employee_directory/value_objects.dart';
import '../host_setup/value_objects.dart';
import 'value_objects.dart';

/// The event contract of the `meetings` bounded context.
const meetingsEventContract = EventContract<MeetingsEvent>(
  context: 'meetings',
  types: {
    'MeetingSlotReservedEvent': MeetingSlotReservedEvent,
    'BookingAvailabilityCheckRequestedEvent': BookingAvailabilityCheckRequestedEvent,
    'BookingSlotVerifiedEvent': BookingSlotVerifiedEvent,
    'CalendarEventRequestedEvent': CalendarEventRequestedEvent,
    'MeetingConfirmedEvent': MeetingConfirmedEvent,
    'MeetingBookingFailedEvent': MeetingBookingFailedEvent,
    'BookingConfirmationSentEvent': BookingConfirmationSentEvent,
    'MeetingRescheduleRequestedEvent': MeetingRescheduleRequestedEvent,
    'RescheduleAvailabilityCheckRequestedEvent': RescheduleAvailabilityCheckRequestedEvent,
    'NewSlotVerifiedEvent': NewSlotVerifiedEvent,
    'CalendarEventUpdateRequestedEvent': CalendarEventUpdateRequestedEvent,
    'MeetingRescheduledEvent': MeetingRescheduledEvent,
    'MeetingMovedInCalendarEvent': MeetingMovedInCalendarEvent,
    'MeetingRescheduleFailedEvent': MeetingRescheduleFailedEvent,
    'RescheduleNoticeSentEvent': RescheduleNoticeSentEvent,
    'MeetingCancellationRequestedEvent': MeetingCancellationRequestedEvent,
    'CalendarEventDeletionRequestedEvent': CalendarEventDeletionRequestedEvent,
    'MeetingCanceledEvent': MeetingCanceledEvent,
    'MeetingCancellationFailedEvent': MeetingCancellationFailedEvent,
    'CancellationNoticeSentEvent': CancellationNoticeSentEvent,
    'MeetingCompletedEvent': MeetingCompletedEvent,
  },
  typeName: meetingsEventTypeName,
  stream: meetingsEventStream,
  tags: meetingsEventTags,
  encode: encodeMeetingsEvent,
  decode: decodeMeetingsEvent,
);

/// The JSON form of [e]. Keys are camelCase field names.
JsonMap encodeMeetingsEvent(MeetingsEvent e) => switch (e) {
  final MeetingSlotReservedEvent e => <String, Object?>{
    'meetingId': e.meetingId.value,
    'hostId': e.hostId.value,
    'bookerId': e.bookerId.value,
    'meetingTypeId': e.meetingTypeId.value,
    'meetingTitle': e.meetingTitle.value,
    'meetingLocation': e.meetingLocation.value,
    'slotStart': e.slotStart.value.toUtc().toIso8601String(),
    'slotEnd': e.slotEnd.value.toUtc().toIso8601String(),
    'participants': _encodeParticipants(e.participants),
  },
  final BookingAvailabilityCheckRequestedEvent e => <String, Object?>{
    'meetingId': e.meetingId.value,
    'hostId': e.hostId.value,
    'slotStart': e.slotStart.value.toUtc().toIso8601String(),
    'slotEnd': e.slotEnd.value.toUtc().toIso8601String(),
  },
  final BookingSlotVerifiedEvent e => <String, Object?>{'meetingId': e.meetingId.value},
  final CalendarEventRequestedEvent e => <String, Object?>{'meetingId': e.meetingId.value},
  final MeetingConfirmedEvent e => <String, Object?>{
    'meetingId': e.meetingId.value,
    'calendarEventId': e.calendarEventId.value,
  },
  final MeetingBookingFailedEvent e => <String, Object?>{
    'meetingId': e.meetingId.value,
    'failureReason': e.failureReason.value,
  },
  final BookingConfirmationSentEvent e => <String, Object?>{
    'meetingId': e.meetingId.value,
    'participants': _encodeParticipants(e.participants),
  },
  final MeetingRescheduleRequestedEvent e => <String, Object?>{
    'meetingId': e.meetingId.value,
    'hostId': e.hostId.value,
    'requestedBy': e.requestedBy.value,
    'newSlotStart': e.newSlotStart.value.toUtc().toIso8601String(),
    'newSlotEnd': e.newSlotEnd.value.toUtc().toIso8601String(),
    'calendarEventId': e.calendarEventId.value,
    'participants': _encodeParticipants(e.participants),
  },
  final RescheduleAvailabilityCheckRequestedEvent e => <String, Object?>{
    'meetingId': e.meetingId.value,
    'hostId': e.hostId.value,
    'newSlotStart': e.newSlotStart.value.toUtc().toIso8601String(),
    'newSlotEnd': e.newSlotEnd.value.toUtc().toIso8601String(),
  },
  final NewSlotVerifiedEvent e => <String, Object?>{'meetingId': e.meetingId.value},
  final CalendarEventUpdateRequestedEvent e => <String, Object?>{
    'meetingId': e.meetingId.value,
    'newSlotStart': e.newSlotStart.value.toUtc().toIso8601String(),
  },
  final MeetingRescheduledEvent e => <String, Object?>{'meetingId': e.meetingId.value},
  final MeetingMovedInCalendarEvent e => <String, Object?>{
    'meetingId': e.meetingId.value,
    'newSlotStart': e.newSlotStart.value.toUtc().toIso8601String(),
    'newSlotEnd': e.newSlotEnd.value.toUtc().toIso8601String(),
  },
  final MeetingRescheduleFailedEvent e => <String, Object?>{
    'meetingId': e.meetingId.value,
    'failureReason': e.failureReason.value,
  },
  final RescheduleNoticeSentEvent e => <String, Object?>{
    'meetingId': e.meetingId.value,
    'newSlotStart': e.newSlotStart.value.toUtc().toIso8601String(),
    'participants': _encodeParticipants(e.participants),
  },
  final MeetingCancellationRequestedEvent e => <String, Object?>{
    'meetingId': e.meetingId.value,
    'hostId': e.hostId.value,
    'requestedBy': e.requestedBy.value,
    'calendarEventId': e.calendarEventId.value,
    'participants': _encodeParticipants(e.participants),
  },
  final CalendarEventDeletionRequestedEvent e => <String, Object?>{'meetingId': e.meetingId.value},
  final MeetingCanceledEvent e => <String, Object?>{'meetingId': e.meetingId.value},
  final MeetingCancellationFailedEvent e => <String, Object?>{
    'meetingId': e.meetingId.value,
    'failureReason': e.failureReason.value,
  },
  final CancellationNoticeSentEvent e => <String, Object?>{
    'meetingId': e.meetingId.value,
    'participants': _encodeParticipants(e.participants),
  },
  final MeetingCompletedEvent e => <String, Object?>{'meetingId': e.meetingId.value},
};

/// The event of type [typeName] that [json] encodes.
///
/// Throws [ArgumentError] for an unknown [typeName].
MeetingsEvent decodeMeetingsEvent(String typeName, JsonMap json) => switch (typeName) {
  'MeetingSlotReservedEvent' => MeetingSlotReservedEvent(
    meetingId: MeetingId(json['meetingId'] as String),
    hostId: HostId(json['hostId'] as String),
    bookerId: BookerId(json['bookerId'] as String),
    meetingTypeId: MeetingTypeId(json['meetingTypeId'] as String),
    meetingTitle: MeetingTitle(json['meetingTitle'] as String),
    meetingLocation: MeetingLocation(json['meetingLocation'] as String),
    slotStart: SlotStart(DateTime.parse(json['slotStart'] as String).toUtc()),
    slotEnd: SlotEnd(DateTime.parse(json['slotEnd'] as String).toUtc()),
    participants: _decodeParticipants(json['participants'] as List<Object?>),
  ),
  'BookingAvailabilityCheckRequestedEvent' => BookingAvailabilityCheckRequestedEvent(
    meetingId: MeetingId(json['meetingId'] as String),
    hostId: HostId(json['hostId'] as String),
    slotStart: SlotStart(DateTime.parse(json['slotStart'] as String).toUtc()),
    slotEnd: SlotEnd(DateTime.parse(json['slotEnd'] as String).toUtc()),
  ),
  'BookingSlotVerifiedEvent' => BookingSlotVerifiedEvent(meetingId: MeetingId(json['meetingId'] as String)),
  'CalendarEventRequestedEvent' => CalendarEventRequestedEvent(meetingId: MeetingId(json['meetingId'] as String)),
  'MeetingConfirmedEvent' => MeetingConfirmedEvent(
    meetingId: MeetingId(json['meetingId'] as String),
    calendarEventId: CalendarEventId(json['calendarEventId'] as String),
  ),
  'MeetingBookingFailedEvent' => MeetingBookingFailedEvent(
    meetingId: MeetingId(json['meetingId'] as String),
    failureReason: FailureReason(json['failureReason'] as String),
  ),
  'BookingConfirmationSentEvent' => BookingConfirmationSentEvent(
    meetingId: MeetingId(json['meetingId'] as String),
    participants: _decodeParticipants(json['participants'] as List<Object?>),
  ),
  'MeetingRescheduleRequestedEvent' => MeetingRescheduleRequestedEvent(
    meetingId: MeetingId(json['meetingId'] as String),
    hostId: HostId(json['hostId'] as String),
    requestedBy: RequestedBy(json['requestedBy'] as String),
    newSlotStart: NewSlotStart(DateTime.parse(json['newSlotStart'] as String).toUtc()),
    newSlotEnd: NewSlotEnd(DateTime.parse(json['newSlotEnd'] as String).toUtc()),
    calendarEventId: CalendarEventId(json['calendarEventId'] as String),
    participants: _decodeParticipants(json['participants'] as List<Object?>),
  ),
  'RescheduleAvailabilityCheckRequestedEvent' => RescheduleAvailabilityCheckRequestedEvent(
    meetingId: MeetingId(json['meetingId'] as String),
    hostId: HostId(json['hostId'] as String),
    newSlotStart: NewSlotStart(DateTime.parse(json['newSlotStart'] as String).toUtc()),
    newSlotEnd: NewSlotEnd(DateTime.parse(json['newSlotEnd'] as String).toUtc()),
  ),
  'NewSlotVerifiedEvent' => NewSlotVerifiedEvent(meetingId: MeetingId(json['meetingId'] as String)),
  'CalendarEventUpdateRequestedEvent' => CalendarEventUpdateRequestedEvent(
    meetingId: MeetingId(json['meetingId'] as String),
    newSlotStart: NewSlotStart(DateTime.parse(json['newSlotStart'] as String).toUtc()),
  ),
  'MeetingRescheduledEvent' => MeetingRescheduledEvent(meetingId: MeetingId(json['meetingId'] as String)),
  'MeetingMovedInCalendarEvent' => MeetingMovedInCalendarEvent(
    meetingId: MeetingId(json['meetingId'] as String),
    newSlotStart: NewSlotStart(DateTime.parse(json['newSlotStart'] as String).toUtc()),
    newSlotEnd: NewSlotEnd(DateTime.parse(json['newSlotEnd'] as String).toUtc()),
  ),
  'MeetingRescheduleFailedEvent' => MeetingRescheduleFailedEvent(
    meetingId: MeetingId(json['meetingId'] as String),
    failureReason: FailureReason(json['failureReason'] as String),
  ),
  'RescheduleNoticeSentEvent' => RescheduleNoticeSentEvent(
    meetingId: MeetingId(json['meetingId'] as String),
    newSlotStart: NewSlotStart(DateTime.parse(json['newSlotStart'] as String).toUtc()),
    participants: _decodeParticipants(json['participants'] as List<Object?>),
  ),
  'MeetingCancellationRequestedEvent' => MeetingCancellationRequestedEvent(
    meetingId: MeetingId(json['meetingId'] as String),
    hostId: HostId(json['hostId'] as String),
    requestedBy: RequestedBy(json['requestedBy'] as String),
    calendarEventId: CalendarEventId(json['calendarEventId'] as String),
    participants: _decodeParticipants(json['participants'] as List<Object?>),
  ),
  'CalendarEventDeletionRequestedEvent' => CalendarEventDeletionRequestedEvent(
    meetingId: MeetingId(json['meetingId'] as String),
  ),
  'MeetingCanceledEvent' => MeetingCanceledEvent(meetingId: MeetingId(json['meetingId'] as String)),
  'MeetingCancellationFailedEvent' => MeetingCancellationFailedEvent(
    meetingId: MeetingId(json['meetingId'] as String),
    failureReason: FailureReason(json['failureReason'] as String),
  ),
  'CancellationNoticeSentEvent' => CancellationNoticeSentEvent(
    meetingId: MeetingId(json['meetingId'] as String),
    participants: _decodeParticipants(json['participants'] as List<Object?>),
  ),
  'MeetingCompletedEvent' => MeetingCompletedEvent(meetingId: MeetingId(json['meetingId'] as String)),
  _ => throw ArgumentError.value(typeName, 'typeName', 'Unknown meetings event type'),
};

List<JsonMap> _encodeParticipants(Participants v) => [
  for (final i in v.items)
    <String, Object?>{'employeeId': i.employeeId.value, 'name': i.name.value, 'email': i.email.value, 'role': i.role},
];

Participants _decodeParticipants(List<Object?> json) => Participants([
  for (final m in json.cast<JsonMap>())
    Participant(
      employeeId: EmployeeId(m['employeeId'] as String),
      name: EmployeeName(m['name'] as String),
      email: EmployeeEmail(m['email'] as String),
      role: m['role'] as String,
    ),
]);
