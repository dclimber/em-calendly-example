import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/meetings/api.dart';
import 'state.dart';

/// The pure view `reschedules_awaiting_live_check`: a requested new time is listed from its `meeting_reschedule_requested`
/// event, and leaves the list when its check is requested, or when the calendar moves or cancels the meeting (a null
/// state deletes the item).
final reschedulesAwaitingLiveCheckView = View<RescheduleAwaitingLiveCheckState?, MeetingsEvent>(
  initialState: null,
  evolve: (state, event) => switch (event) {
    MeetingRescheduleRequestedEvent() => RescheduleAwaitingLiveCheckState(
      meetingId: event.meetingId,
      hostId: event.hostId,
      newSlotStart: event.newSlotStart,
      newSlotEnd: event.newSlotEnd,
    ),
    RescheduleAvailabilityCheckRequestedEvent() => null,
    MeetingMovedInCalendarEvent() => null,
    MeetingCanceledEvent() => null,
    _ => state,
  },
);
