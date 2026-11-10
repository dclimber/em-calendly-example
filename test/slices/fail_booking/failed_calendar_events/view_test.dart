import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/fail_booking/failed_calendar_events/state.dart';
import 'package:em_calendly_example/slices/fail_booking/failed_calendar_events/view.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

void main() {
  // @requires a host_slot_found_busy answer for a meeting
  // @ensures scenario busy_answer_lists_the_booking: the answer lists its meeting with the busy reason text
  test('busy_answer_lists_the_booking', () {
    final v = failedCalendarEventsView;
    expect(
      v.evolve(v.initialState, busyAnswer(meetingId: 'meeting-1')),
      FailedCalendarEventState(
        meetingId: MeetingId('meeting-1'),
        failureReason: FailureReason('This time is no longer available. Please choose another slot.'),
      ),
    );
  });

  // @requires an availability_check_failed answer, whose failure code is not the reason
  // @ensures the answer lists its meeting with the fixed availability reason text, not the failure code
  test('availability_failure_lists_the_booking_with_fixed_text', () {
    final v = failedCalendarEventsView;
    expect(
      v.evolve(v.initialState, availabilityFailedAnswer(meetingId: 'meeting-1')),
      FailedCalendarEventState(
        meetingId: MeetingId('meeting-1'),
        failureReason: FailureReason(
          "The host's availability cannot be verified right now. Please try again later.",
        ),
      ),
    );
  });

  // @requires a calendar_event_creation_failed answer with a failure code
  // @ensures the answer lists its meeting with that failure code as the reason
  test('creation_failure_keeps_its_failure_code', () {
    final v = failedCalendarEventsView;
    expect(
      v.evolve(v.initialState, creationFailedAnswer(meetingId: 'meeting-2', code: 'calendar_refused')),
      FailedCalendarEventState(meetingId: MeetingId('meeting-2'), failureReason: FailureReason('calendar_refused')),
    );
  });

  // @requires a booking_availability_check_requested event, or a reservation, which opens no item
  // @ensures neither event lists anything
  test('a request or reservation lists nothing', () {
    final v = failedCalendarEventsView;
    final requested = BookingAvailabilityCheckRequestedEvent(
      meetingId: MeetingId('meeting-1'),
      hostId: HostId('alice-employee-id'),
      slotStart: SlotStart(DateTime.utc(2027, 3, 15, 9)),
      slotEnd: SlotEnd(DateTime.utc(2027, 3, 15, 9, 30)),
    );
    expect(v.evolve(v.initialState, requested), isNull);
    expect(v.evolve(v.initialState, reservedEvent()), isNull);
  });
}
