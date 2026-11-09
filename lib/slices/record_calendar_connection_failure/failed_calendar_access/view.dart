import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/corporate_calendar/api.dart';
import '../../../bounded_contexts/host_setup/api.dart';
import 'state.dart';

/// The pure view `failed_calendar_access`: the access failure that a `calendar_access_failed` event reports.
/// It is not materialized: the handler folds the one event that it receives, and the processor reads the result.
final failedCalendarAccessView = View<FailedCalendarAccessState?, CorporateCalendarEvent>(
  initialState: null,
  evolve: (state, event) => switch (event) {
    CalendarAccessFailedEvent() => FailedCalendarAccessState(
      hostId: HostId(event.schedulerUserRef.value),
      connectionFailure: ConnectionFailure(event.failureCode.value),
    ),
    _ => state,
  },
);
