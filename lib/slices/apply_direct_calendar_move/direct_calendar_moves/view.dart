import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/corporate_calendar/api.dart';
import '../../../bounded_contexts/meetings/api.dart';
import 'state.dart';

/// The pure view `direct_calendar_moves`: a `calendar_event_moved_directly` event lists its meeting with the moved times.
final directCalendarMovesView = View<DirectCalendarMoveState?, DomainEvent>(
  initialState: null,
  evolve: (state, event) => switch (event) {
    CalendarEventMovedDirectlyEvent() => DirectCalendarMoveState(
      meetingId: MeetingId(event.schedulerMeetingRef.value),
      newSlotStart: NewSlotStart(event.movedStart),
      newSlotEnd: NewSlotEnd(event.movedEnd),
    ),
    _ => state,
  },
);
