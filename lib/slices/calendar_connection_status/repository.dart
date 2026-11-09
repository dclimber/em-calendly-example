import '../../bounded_contexts/host_setup/api.dart';
import '../../platform/event_store/event_store.dart';
import '../../platform/view_store/materialized_view.dart';
import 'state.dart';

/// The document store of `calendar_connection_status`: one document per host id.
final class CalendarConnectionStatusRepository extends DocumentViewStateRepository<CalendarConnectionStatus> {
  CalendarConnectionStatusRepository(super.store);

  @override
  String get viewName => 'calendar_connection_status';

  @override
  String? keyOf(StoredEvent event) => switch (event.event) {
    CalendarConnectionStartedEvent(:final hostId) => hostId.value,
    CalendarConnectedEvent(:final hostId) => hostId.value,
    CalendarConnectionFailedEvent(:final hostId) => hostId.value,
    _ => null,
  };

  @override
  String keyOfState(CalendarConnectionStatus state) => state.hostId.value;

  @override
  JsonMap encodeState(CalendarConnectionStatus state) => state.toJson();

  @override
  CalendarConnectionStatus decodeState(JsonMap json) => CalendarConnectionStatus.fromJson(json);
}
