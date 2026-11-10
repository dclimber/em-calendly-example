import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/meetings/api.dart';

/// The calendar event ids that the meeting already recorded as confirmed. This is the deduplication state of
/// `calendar_event_created`: a repeated event for a recorded id sends no command.
final class RecordedCalendarEventsState {
  const RecordedCalendarEventsState({this.calendarEventIds = const {}});

  final Set<CalendarEventId> calendarEventIds;

  bool contains(CalendarEventId id) => calendarEventIds.contains(id);

  @override
  bool operator ==(Object other) =>
      other is RecordedCalendarEventsState &&
      other.calendarEventIds.length == calendarEventIds.length &&
      calendarEventIds.every(other.calendarEventIds.contains);

  @override
  int get hashCode => calendarEventIds.fold(0, (hash, id) => hash ^ id.hashCode);

  @override
  String toString() => 'RecordedCalendarEventsState(calendarEventIds: $calendarEventIds)';
}

/// Folds the history of one meeting into the calendar event ids it recorded as confirmed.
final recordedCalendarEventsView = View<RecordedCalendarEventsState, MeetingsEvent>(
  initialState: const RecordedCalendarEventsState(),
  evolve: (state, event) => switch (event) {
    MeetingConfirmedEvent() => RecordedCalendarEventsState(
      calendarEventIds: {...state.calendarEventIds, event.calendarEventId},
    ),
    _ => state,
  },
);
