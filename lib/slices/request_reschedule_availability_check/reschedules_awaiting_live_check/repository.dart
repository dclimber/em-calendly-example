import '../../../bounded_contexts/host_setup/api.dart';
import '../../../bounded_contexts/meetings/api.dart';
import '../../../platform/event_store/event_store.dart';
import '../../../platform/view_store/materialized_view.dart';
import 'state.dart';

/// The document store of `reschedules_awaiting_live_check`, one document per requested new time, keyed by its meeting.
final class ReschedulesAwaitingLiveCheckRepository
    extends DocumentViewStateRepository<RescheduleAwaitingLiveCheckState> {
  ReschedulesAwaitingLiveCheckRepository(super.store);

  @override
  String get viewName => 'reschedules_awaiting_live_check';

  @override
  String? keyOf(StoredEvent event) => event.tagValue('meetingId');

  @override
  String keyOfState(RescheduleAwaitingLiveCheckState state) => state.meetingId.value;

  @override
  JsonMap encodeState(RescheduleAwaitingLiveCheckState state) => {
    'meetingId': state.meetingId.value,
    'hostId': state.hostId.value,
    'newSlotStart': state.newSlotStart.value.toUtc().toIso8601String(),
    'newSlotEnd': state.newSlotEnd.value.toUtc().toIso8601String(),
  };

  @override
  RescheduleAwaitingLiveCheckState decodeState(JsonMap json) => RescheduleAwaitingLiveCheckState(
    meetingId: MeetingId(json['meetingId'] as String),
    hostId: HostId(json['hostId'] as String),
    newSlotStart: NewSlotStart(DateTime.parse(json['newSlotStart'] as String)),
    newSlotEnd: NewSlotEnd(DateTime.parse(json['newSlotEnd'] as String)),
  );
}
