import '../../../bounded_contexts/employee_directory/api.dart';
import '../../../bounded_contexts/host_setup/api.dart';
import '../../../bounded_contexts/meetings/api.dart';
import '../../../platform/event_store/event_store.dart';
import '../../../platform/view_store/materialized_view.dart';
import 'state.dart';

/// The document store of `reservations_awaiting_calendar_event`, one document per held slot, keyed by its meeting.
final class ReservationsAwaitingCalendarEventRepository
    extends DocumentViewStateRepository<ReservationAwaitingCalendarEventState> {
  ReservationsAwaitingCalendarEventRepository(super.store);

  @override
  String get viewName => 'reservations_awaiting_calendar_event';

  @override
  String? keyOf(StoredEvent event) => event.tagValue('meetingId');

  @override
  String keyOfState(ReservationAwaitingCalendarEventState state) => state.meetingId.value;

  @override
  JsonMap encodeState(ReservationAwaitingCalendarEventState state) => {
    'meetingId': state.meetingId.value,
    'hostId': state.hostId.value,
    'meetingTitle': state.meetingTitle.value,
    'meetingLocation': state.meetingLocation.value,
    'slotStart': state.slotStart.value.toUtc().toIso8601String(),
    'slotEnd': state.slotEnd.value.toUtc().toIso8601String(),
    'participants': [
      for (final p in state.participants.items)
        <String, Object?>{
          'employeeId': p.employeeId.value,
          'name': p.name.value,
          'email': p.email.value,
          'role': p.role,
        },
    ],
    'verified': state.verified,
  };

  @override
  ReservationAwaitingCalendarEventState decodeState(JsonMap json) => ReservationAwaitingCalendarEventState(
    meetingId: MeetingId(json['meetingId'] as String),
    hostId: HostId(json['hostId'] as String),
    meetingTitle: MeetingTitle(json['meetingTitle'] as String),
    meetingLocation: MeetingLocation(json['meetingLocation'] as String),
    slotStart: SlotStart(DateTime.parse(json['slotStart'] as String)),
    slotEnd: SlotEnd(DateTime.parse(json['slotEnd'] as String)),
    participants: Participants([
      for (final m in (json['participants'] as List<Object?>).cast<JsonMap>())
        Participant(
          employeeId: EmployeeId(m['employeeId'] as String),
          name: EmployeeName(m['name'] as String),
          email: EmployeeEmail(m['email'] as String),
          role: m['role'] as String,
        ),
    ]),
    verified: json['verified'] as bool,
  );
}
