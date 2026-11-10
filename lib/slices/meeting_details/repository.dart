import '../../bounded_contexts/meetings/api.dart';
import '../../platform/event_store/event_store.dart';
import '../../platform/view_store/materialized_view.dart';
import 'state.dart';

/// The document store of `meeting_details`: one document per meeting id, holding the participant ids.
final class MeetingDetailsRepository extends DocumentViewStateRepository<MeetingDetails> {
  MeetingDetailsRepository(super.store);

  @override
  String get viewName => 'meeting_details';

  @override
  String? keyOf(StoredEvent event) => switch (event.event) {
    MeetingSlotReservedEvent(:final meetingId) => meetingId.value,
    MeetingConfirmedEvent(:final meetingId) => meetingId.value,
    MeetingRescheduleRequestedEvent(:final meetingId) => meetingId.value,
    MeetingRescheduledEvent(:final meetingId) => meetingId.value,
    MeetingMovedInCalendarEvent(:final meetingId) => meetingId.value,
    MeetingRescheduleFailedEvent(:final meetingId) => meetingId.value,
    MeetingCancellationRequestedEvent(:final meetingId) => meetingId.value,
    MeetingCanceledEvent(:final meetingId) => meetingId.value,
    MeetingCancellationFailedEvent(:final meetingId) => meetingId.value,
    MeetingCompletedEvent(:final meetingId) => meetingId.value,
    _ => null,
  };

  @override
  String keyOfState(MeetingDetails state) => state.meetingId.value;

  @override
  Map<String, Object?> encodeState(MeetingDetails state) => state.toJson();

  @override
  MeetingDetails decodeState(Map<String, Object?> json) => MeetingDetails.fromJson(json);
}
