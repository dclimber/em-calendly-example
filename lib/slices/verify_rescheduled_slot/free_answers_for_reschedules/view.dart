import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/corporate_calendar/api.dart';
import '../../../bounded_contexts/meetings/api.dart';
import 'state.dart';

/// The pure view `free_answers_for_reschedules`: a `host_slot_found_free` answer lists its meeting, named by the
/// scheduler meeting ref, which is the meeting id.
///
/// The `reschedule_availability_check_requested` event opens no item, so it yields null. The answer alone decides
/// whether a meeting is listed: the decider refuses any meeting that is not rescheduling, so an answer of another kind
/// of check (a booking, for example) cannot verify a new slot.
final freeAnswersForReschedulesView = View<FreeAnswerForRescheduleState?, DomainEvent>(
  initialState: null,
  evolve: (state, event) => switch (event) {
    HostSlotFoundFreeEvent() => FreeAnswerForRescheduleState(meetingId: MeetingId(event.schedulerMeetingRef.value)),
    RescheduleAvailabilityCheckRequestedEvent() => null,
    _ => state,
  },
);
