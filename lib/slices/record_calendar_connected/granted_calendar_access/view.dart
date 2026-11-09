import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/corporate_calendar/api.dart';
import '../../../bounded_contexts/host_setup/api.dart';
import 'state.dart';

/// The pure view `granted_calendar_access`: the calendar access that a `calendar_access_granted` event reports.
/// It is not materialized: the handler folds the one event that it receives, and the processor reads the result.
final grantedCalendarAccessView = View<GrantedCalendarAccessState?, CorporateCalendarEvent>(
  initialState: null,
  evolve: (state, event) => switch (event) {
    CalendarAccessGrantedEvent() => GrantedCalendarAccessState(
      hostId: HostId(event.schedulerUserRef.value),
      calendarAccount: CalendarAccount(event.calendarAccount),
    ),
    _ => state,
  },
);
