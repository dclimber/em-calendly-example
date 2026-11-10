import '../../../bounded_contexts/meetings/api.dart';
import '../../../platform/event_store/event_store.dart';
import '../../../platform/view_store/materialized_view.dart';
import 'state.dart';

/// The document store of `reschedules_awaiting_calendar_update`, one document per reschedule, keyed by its meeting.
final class ReschedulesAwaitingCalendarUpdateRepository
    extends DocumentViewStateRepository<ReschedulesAwaitingCalendarUpdateState> {
  ReschedulesAwaitingCalendarUpdateRepository(super.store);

  @override
  String get viewName => 'reschedules_awaiting_calendar_update';

  @override
  String? keyOf(StoredEvent event) => event.tagValue('meetingId');

  @override
  String keyOfState(ReschedulesAwaitingCalendarUpdateState state) => state.meetingId.value;

  @override
  JsonMap encodeState(ReschedulesAwaitingCalendarUpdateState state) => {
    'meetingId': state.meetingId.value,
    'newSlotStart': state.newSlotStart.value.toUtc().toIso8601String(),
    'newSlotEnd': state.newSlotEnd.value.toUtc().toIso8601String(),
    'calendarEventId': state.calendarEventId.value,
    'verified': state.verified,
  };

  @override
  ReschedulesAwaitingCalendarUpdateState decodeState(JsonMap json) => ReschedulesAwaitingCalendarUpdateState(
    meetingId: MeetingId(json['meetingId'] as String),
    newSlotStart: NewSlotStart(DateTime.parse(json['newSlotStart'] as String)),
    newSlotEnd: NewSlotEnd(DateTime.parse(json['newSlotEnd'] as String)),
    calendarEventId: CalendarEventId(json['calendarEventId'] as String),
    verified: json['verified'] as bool,
  );
}
