import '../../../bounded_contexts/meetings/api.dart';
import '../../../platform/event_store/event_store.dart';
import '../../../platform/view_store/materialized_view.dart';
import 'state.dart';

/// The document store of `meetings_to_complete`, one document per meeting id.
final class MeetingsToCompleteRepository extends DocumentViewStateRepository<MeetingToComplete> {
  MeetingsToCompleteRepository(super.store);

  @override
  String get viewName => 'meetings_to_complete';

  @override
  String? keyOf(StoredEvent event) => switch (event.event) {
    MeetingSlotReservedEvent(:final meetingId) => meetingId.value,
    MeetingConfirmedEvent(:final meetingId) => meetingId.value,
    MeetingRescheduleRequestedEvent(:final meetingId) => meetingId.value,
    MeetingRescheduledEvent(:final meetingId) => meetingId.value,
    MeetingMovedInCalendarEvent(:final meetingId) => meetingId.value,
    MeetingCanceledEvent(:final meetingId) => meetingId.value,
    MeetingCompletedEvent(:final meetingId) => meetingId.value,
    _ => null,
  };

  @override
  String keyOfState(MeetingToComplete state) => state.meetingId.value;

  @override
  Map<String, Object?> encodeState(MeetingToComplete state) => state.toJson();

  @override
  MeetingToComplete decodeState(Map<String, Object?> json) => MeetingToComplete.fromJson(json);
}
