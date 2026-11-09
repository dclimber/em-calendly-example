import '../../bounded_contexts/host_setup/api.dart';
import '../../platform/event_store/event_store.dart';
import '../../platform/view_store/materialized_view.dart';
import 'state.dart';

/// The document store of `my_meeting_types`: one document per meeting type id.
final class MyMeetingTypesRepository extends DocumentViewStateRepository<MyMeetingType> {
  MyMeetingTypesRepository(super.store);

  @override
  String get viewName => 'my_meeting_types';

  @override
  String? keyOf(StoredEvent event) => switch (event.event) {
    MeetingTypeCreatedEvent(:final meetingTypeId) => meetingTypeId.value,
    MeetingTypeEditedEvent(:final meetingTypeId) => meetingTypeId.value,
    MeetingTypeDisabledEvent(:final meetingTypeId) => meetingTypeId.value,
    MeetingTypeEnabledEvent(:final meetingTypeId) => meetingTypeId.value,
    MeetingTypeDeletedEvent(:final meetingTypeId) => meetingTypeId.value,
    _ => null,
  };

  @override
  String keyOfState(MyMeetingType state) => state.meetingTypeId.value;

  @override
  JsonMap encodeState(MyMeetingType state) => state.toJson();

  @override
  MyMeetingType decodeState(JsonMap json) => MyMeetingType.fromJson(json);
}
