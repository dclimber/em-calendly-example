import '../../bounded_contexts/host_setup/api.dart';
import '../../bounded_contexts/meetings/api.dart';

/// A time range `[start, end)` in UTC.
typedef SlotSpan = ({DateTime start, DateTime end});

/// The time that one meeting holds: its current slot, and a requested slot while a reschedule is pending.
typedef HeldSlot = ({SlotSpan? current, SlotSpan? pending});

/// The facts of one booked meeting that a reschedule decides on, from its `meeting_slot_reserved`.
final class ReschedulableBooking {
  const ReschedulableBooking({
    required this.hostId,
    required this.bookerId,
    required this.participants,
    required this.duration,
  });

  final String hostId;
  final String bookerId;
  final Participants participants;

  /// The length of the booked slot. A reschedule keeps it.
  final Duration duration;
}

/// The state that `request_meeting_reschedule` decides on, folded from the meeting's own events, the events of its
/// host, and the events of its meeting type's schedule: the schedule, calendar status, busy times, and every held slot
/// of the host's meetings.
final class RescheduleState {
  const RescheduleState({
    this.schedules = const {},
    this.calendarFailed = false,
    this.busy = const [],
    this.held = const {},
    this.bookings = const {},
    this.lifecycles = const {},
    this.calendarEventIds = const {},
  });

  /// The availability rules by schedule id. The repository reads only the schedule of the command's meeting type, so
  /// this holds that one schedule. A schedule is absent until it is created.
  final Map<String, ScheduleRules> schedules;
  final bool calendarFailed;
  final List<SlotSpan> busy;

  /// The held slots by meeting id.
  final Map<String, HeldSlot> held;

  /// The booked facts by meeting id, from `meeting_slot_reserved`.
  final Map<String, ReschedulableBooking> bookings;

  /// The lifecycle state by meeting id.
  final Map<String, MeetingLifecycleState> lifecycles;

  /// The calendar event id by meeting id, from `meeting_confirmed`.
  final Map<String, String> calendarEventIds;

  RescheduleState copyWith({
    Map<String, ScheduleRules>? schedules,
    bool? calendarFailed,
    List<SlotSpan>? busy,
    Map<String, HeldSlot>? held,
    Map<String, ReschedulableBooking>? bookings,
    Map<String, MeetingLifecycleState>? lifecycles,
    Map<String, String>? calendarEventIds,
  }) => RescheduleState(
    schedules: schedules ?? this.schedules,
    calendarFailed: calendarFailed ?? this.calendarFailed,
    busy: busy ?? this.busy,
    held: held ?? this.held,
    bookings: bookings ?? this.bookings,
    lifecycles: lifecycles ?? this.lifecycles,
    calendarEventIds: calendarEventIds ?? this.calendarEventIds,
  );
}

/// The schedule fields that the booking rules need, in the shape of `AvailabilityRules`.
final class ScheduleRules {
  const ScheduleRules({
    required this.timeZone,
    this.weeklyHours = const [],
    this.dateExceptions = const {},
    this.bookingWindowDays,
    this.minimumNoticeMinutes = 0,
    this.bufferBeforeMinutes = 0,
    this.bufferAfterMinutes = 0,
  });

  final String timeZone;
  final List<WeeklyHoursEntry> weeklyHours;
  final Map<DateTime, List<ExceptionHoursRange>> dateExceptions;
  final int? bookingWindowDays;
  final int minimumNoticeMinutes;
  final int bufferBeforeMinutes;
  final int bufferAfterMinutes;

  ScheduleRules copyWith({
    List<WeeklyHoursEntry>? weeklyHours,
    Map<DateTime, List<ExceptionHoursRange>>? dateExceptions,
    int? bookingWindowDays,
    int? minimumNoticeMinutes,
    int? bufferBeforeMinutes,
    int? bufferAfterMinutes,
  }) => ScheduleRules(
    timeZone: timeZone,
    weeklyHours: weeklyHours ?? this.weeklyHours,
    dateExceptions: dateExceptions ?? this.dateExceptions,
    bookingWindowDays: bookingWindowDays ?? this.bookingWindowDays,
    minimumNoticeMinutes: minimumNoticeMinutes ?? this.minimumNoticeMinutes,
    bufferBeforeMinutes: bufferBeforeMinutes ?? this.bufferBeforeMinutes,
    bufferAfterMinutes: bufferAfterMinutes ?? this.bufferAfterMinutes,
  );
}
