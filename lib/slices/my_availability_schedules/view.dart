import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/host_setup/api.dart';
import 'state.dart';

/// The pure view of `my_availability_schedules`, one document per schedule. The schedule is created by
/// `availability_schedule_created`, which holds the host id. Every other event changes only the document of its own
/// schedule. A changed exception replaces the hours of its date. A removed exception leaves the list. Events that
/// arrive before their schedule was created change nothing.
final availabilitySchedulesView = View<AvailabilitySchedule?, HostSetupEvent>(
  initialState: null,
  evolve: (state, event) => switch (event) {
    AvailabilityScheduleCreatedEvent(:final scheduleId, :final hostId, :final scheduleName, :final timeZone) =>
      AvailabilitySchedule(
        scheduleId: scheduleId,
        hostId: hostId,
        scheduleName: scheduleName,
        timeZone: timeZone,
      ),
    WeeklyHoursSetEvent(:final weeklyHours) => state?.withWeeklyHours(weeklyHours),
    DateExceptionAddedEvent(:final exceptionDate, :final exceptionHours) => state?.withDateException(
      DateException(exceptionDate: exceptionDate.value, hours: exceptionHours),
    ),
    DateExceptionChangedEvent(:final exceptionDate, :final exceptionHours) => state?.withDateException(
      DateException(exceptionDate: exceptionDate.value, hours: exceptionHours),
    ),
    DateExceptionRemovedEvent(:final exceptionDate) => state?.withoutDateException(exceptionDate.value),
    BookingLimitsSetEvent(
      :final bookingWindowDays,
      :final minimumNoticeMinutes,
      :final bufferBeforeMinutes,
      :final bufferAfterMinutes,
    ) =>
      state?.withBookingLimits(
        bookingWindowDays: bookingWindowDays,
        minimumNoticeMinutes: minimumNoticeMinutes,
        bufferBeforeMinutes: bufferBeforeMinutes,
        bufferAfterMinutes: bufferAfterMinutes,
      ),
    _ => state,
  },
);
