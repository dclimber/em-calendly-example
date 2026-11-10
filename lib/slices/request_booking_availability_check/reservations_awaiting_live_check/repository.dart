import '../../../bounded_contexts/host_setup/api.dart';
import '../../../bounded_contexts/meetings/api.dart';
import '../../../platform/event_store/event_store.dart';
import '../../../platform/view_store/materialized_view.dart';
import 'state.dart';

/// The document store of `reservations_awaiting_live_check`, one document per held slot, keyed by its meeting.
final class ReservationsAwaitingLiveCheckRepository
    extends DocumentViewStateRepository<ReservationAwaitingLiveCheckState> {
  ReservationsAwaitingLiveCheckRepository(super.store);

  @override
  String get viewName => 'reservations_awaiting_live_check';

  @override
  String? keyOf(StoredEvent event) => event.tagValue('meetingId');

  @override
  String keyOfState(ReservationAwaitingLiveCheckState state) => state.meetingId.value;

  @override
  JsonMap encodeState(ReservationAwaitingLiveCheckState state) => {
    'meetingId': state.meetingId.value,
    'hostId': state.hostId.value,
    'slotStart': state.slotStart.value.toUtc().toIso8601String(),
    'slotEnd': state.slotEnd.value.toUtc().toIso8601String(),
  };

  @override
  ReservationAwaitingLiveCheckState decodeState(JsonMap json) => ReservationAwaitingLiveCheckState(
    meetingId: MeetingId(json['meetingId'] as String),
    hostId: HostId(json['hostId'] as String),
    slotStart: SlotStart(DateTime.parse(json['slotStart'] as String)),
    slotEnd: SlotEnd(DateTime.parse(json['slotEnd'] as String)),
  );
}
