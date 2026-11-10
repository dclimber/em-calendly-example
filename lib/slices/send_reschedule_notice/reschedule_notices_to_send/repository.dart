import '../../../bounded_contexts/employee_directory/api.dart';
import '../../../bounded_contexts/host_setup/api.dart';
import '../../../bounded_contexts/meetings/api.dart';
import '../../../platform/event_store/event_store.dart';
import '../../../platform/view_store/materialized_view.dart';
import 'state.dart';

/// The document store of `reschedule_notices_to_send`, one document per meeting.
final class RescheduleNoticesToSendRepository extends DocumentViewStateRepository<RescheduleNoticeToSendState> {
  RescheduleNoticesToSendRepository(super.store);

  @override
  String get viewName => 'reschedule_notices_to_send';

  @override
  String? keyOf(StoredEvent event) => event.tagValue('meetingId');

  @override
  String keyOfState(RescheduleNoticeToSendState state) => state.meetingId.value;

  @override
  JsonMap encodeState(RescheduleNoticeToSendState state) => {
    'meetingId': state.meetingId.value,
    'meetingTitle': state.meetingTitle?.value,
    'newSlotStart': state.newSlotStart.value.toUtc().toIso8601String(),
    'newSlotEnd': state.newSlotEnd.value.toUtc().toIso8601String(),
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
  RescheduleNoticeToSendState decodeState(JsonMap json) {
    final title = json['meetingTitle'] as String?;
    return RescheduleNoticeToSendState(
      meetingId: MeetingId(json['meetingId'] as String),
      meetingTitle: title == null ? null : MeetingTitle(title),
      newSlotStart: NewSlotStart(DateTime.parse(json['newSlotStart'] as String)),
      newSlotEnd: NewSlotEnd(DateTime.parse(json['newSlotEnd'] as String)),
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
}
