import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/corporate_calendar/api.dart';
import '../../../bounded_contexts/meetings/api.dart';
import 'state.dart';

/// The pure view `free_answers_for_bookings`: a `host_slot_found_free` answer lists its meeting, named by the
/// scheduler meeting ref, which is the meeting id.
///
/// The `booking_availability_check_requested` event opens no item, so it yields null. The answer alone decides
/// whether a meeting is listed: the decider refuses any meeting that is not pending_calendar, so an answer of
/// another kind of check (a reschedule, for example) cannot book a slot.
final freeAnswersForBookingsView = View<FreeAnswerForBookingState?, DomainEvent>(
  initialState: null,
  evolve: (state, event) => switch (event) {
    HostSlotFoundFreeEvent() => FreeAnswerForBookingState(meetingId: MeetingId(event.schedulerMeetingRef.value)),
    BookingAvailabilityCheckRequestedEvent() => null,
    _ => state,
  },
);
