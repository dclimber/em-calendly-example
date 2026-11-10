import '../../bounded_contexts/meetings/api.dart';
import '../../platform/event_store/event_store.dart';
import '../../platform/view_store/materialized_view.dart';
import 'state.dart';

/// The document store of `hosted_meetings`: one document per meeting id.
final class HostedMeetingsRepository extends DocumentViewStateRepository<HostedMeeting> {
  HostedMeetingsRepository(super.store);

  @override
  String get viewName => 'hosted_meetings';

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
  String keyOfState(HostedMeeting state) => state.meetingId.value;

  @override
  Map<String, Object?> encodeState(HostedMeeting state) => state.toJson();

  @override
  HostedMeeting decodeState(Map<String, Object?> json) => HostedMeeting.fromJson(json);
}
