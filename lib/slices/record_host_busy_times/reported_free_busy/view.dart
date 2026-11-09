import 'package:fmodel/fmodel.dart';

import '../../../bounded_contexts/corporate_calendar/api.dart';
import '../../../bounded_contexts/host_setup/api.dart';
import 'state.dart';

/// The pure view `reported_free_busy`: the free/busy data that a `free_busy_reported` event carries.
/// It is not materialized: the handler folds the one event that it receives, and the processor reads the result.
///
/// The field source maps `scheduler_user_ref` to `host_id`, and `free_busy_blocks` to `busy_intervals`. Each block
/// keeps its `busy_from` and `busy_until`, in the same order.
final reportedFreeBusyView = View<ReportedFreeBusyState?, CorporateCalendarEvent>(
  initialState: null,
  evolve: (state, event) => switch (event) {
    FreeBusyReportedEvent() => ReportedFreeBusyState(
      hostId: HostId(event.schedulerUserRef.value),
      busyIntervals: BusyIntervals(
        event.freeBusyBlocks.items.map((block) => BusyInterval(busyFrom: block.busyFrom, busyUntil: block.busyUntil)),
      ),
    ),
    _ => state,
  },
);
