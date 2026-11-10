import '../../../bounded_contexts/employee_directory/api.dart';
import '../../../bounded_contexts/host_setup/api.dart';
import '../../../bounded_contexts/meetings/api.dart';
import '../../../platform/event_store/event_store.dart';
import '../../../platform/view_store/materialized_view.dart';
import 'state.dart';

/// The document store of `cancellation_notices_to_send`, one document per meeting.
final class CancellationNoticesToSendRepository extends DocumentViewStateRepository<CancellationNoticeToSendState> {
  CancellationNoticesToSendRepository(super.store);

  @override
  String get viewName => 'cancellation_notices_to_send';

  @override
  String? keyOf(StoredEvent event) => event.tagValue('meetingId');

  @override
  String keyOfState(CancellationNoticeToSendState state) => state.meetingId.value;

  @override
  JsonMap encodeState(CancellationNoticeToSendState state) => {
    'meetingId': state.meetingId.value,
    'meetingTitle': state.meetingTitle.value,
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
    'ready': state.ready,
  };

  @override
  CancellationNoticeToSendState decodeState(JsonMap json) => CancellationNoticeToSendState(
    meetingId: MeetingId(json['meetingId'] as String),
    meetingTitle: MeetingTitle(json['meetingTitle'] as String),
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
    ready: json['ready'] as bool,
  );
}
