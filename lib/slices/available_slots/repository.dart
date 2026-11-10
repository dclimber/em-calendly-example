import '../../bounded_contexts/employee_directory/api.dart';
import '../../platform/event_store/event_store.dart';
import '../../platform/view_store/materialized_view.dart';
import 'state.dart';

/// The document store of `available_slots`: one document per host, keyed by the host id. The host id is the
/// `employee_id` of the employee who registered, and the `hostId` tag of every schedule, meeting type, and meeting
/// event.
final class AvailableSlotsRepository extends DocumentViewStateRepository<AvailableSlotsState> {
  AvailableSlotsRepository(super.store);

  @override
  String get viewName => 'available_slots';

  @override
  String? keyOf(StoredEvent event) => switch (event.event) {
    EmployeeRegisteredEvent(:final employeeId) => employeeId.value,
    _ => event.tagValue('hostId'),
  };

  @override
  String keyOfState(AvailableSlotsState state) => state.hostId;

  @override
  JsonMap encodeState(AvailableSlotsState state) => state.toJson();

  @override
  AvailableSlotsState decodeState(JsonMap json) => AvailableSlotsState.fromJson(json);

  /// The host document of the meeting type [meetingTypeId], or null when no host has such a meeting type.
  Future<AvailableSlotsState?> ofMeetingType(String meetingTypeId) async {
    final found = await findWhere({
      'meetingTypes': {meetingTypeId: <String, Object?>{}},
    });
    return found.isEmpty ? null : found.first;
  }

  /// The host document of the meeting [meetingId], or null when no host has such a meeting.
  Future<AvailableSlotsState?> ofMeeting(String meetingId) async {
    final found = await findWhere({
      'meetings': {meetingId: <String, Object?>{}},
    });
    return found.isEmpty ? null : found.first;
  }
}
