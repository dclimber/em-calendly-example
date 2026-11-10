import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/confirm_booked_meeting/created_calendar_events/state.dart';
import 'package:em_calendly_example/slices/confirm_booked_meeting/created_calendar_events/view.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

void main() {
  // @requires a calendar_event_created event for a meeting
  // @ensures scenario created_event_is_listed: the event lists its meeting, with the provider event ref as calendar id
  test('created_event_is_listed', () {
    final v = createdCalendarEventsView;
    expect(
      v.evolve(v.initialState, createdEvent(meetingId: 'meeting-1', calendarEventId: 'cal-1')),
      CreatedCalendarEventState(meetingId: MeetingId('meeting-1'), calendarEventId: CalendarEventId('cal-1')),
    );
  });

  // @requires a meeting_slot_reserved event, which is not a calendar event of the calendar system
  // @ensures the reservation lists nothing
  test('a reservation lists nothing', () {
    final v = createdCalendarEventsView;
    expect(v.evolve(v.initialState, reservedEvent()), isNull);
  });
}
