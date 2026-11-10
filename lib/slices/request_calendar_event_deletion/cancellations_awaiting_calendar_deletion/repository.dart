import '../../../bounded_contexts/meetings/api.dart';
import '../../../platform/event_store/event_store.dart';
import '../../../platform/view_store/materialized_view.dart';
import 'state.dart';

/// The document store of `cancellations_awaiting_calendar_deletion`, one document per requested cancellation, keyed by
/// its meeting.
final class CancellationsAwaitingCalendarDeletionRepository
    extends DocumentViewStateRepository<CancellationAwaitingCalendarDeletionState> {
  CancellationsAwaitingCalendarDeletionRepository(super.store);

  @override
  String get viewName => 'cancellations_awaiting_calendar_deletion';

  @override
  String? keyOf(StoredEvent event) => event.tagValue('meetingId');

  @override
  String keyOfState(CancellationAwaitingCalendarDeletionState state) => state.meetingId.value;

  @override
  JsonMap encodeState(CancellationAwaitingCalendarDeletionState state) => {
    'meetingId': state.meetingId.value,
    'calendarEventId': state.calendarEventId.value,
  };

  @override
  CancellationAwaitingCalendarDeletionState decodeState(JsonMap json) => CancellationAwaitingCalendarDeletionState(
    meetingId: MeetingId(json['meetingId'] as String),
    calendarEventId: CalendarEventId(json['calendarEventId'] as String),
  );
}
