import '../../bounded_contexts/host_setup/api.dart';

/// The meeting type facts that a booking reads.
final class BookableMeetingType {
  const BookableMeetingType({
    required this.hostId,
    required this.scheduleId,
    required this.title,
    required this.location,
    required this.durationMinutes,
    required this.accepting,
    required this.deleted,
  });

  final String hostId;
  final String scheduleId;
  final String title;
  final String location;
  final int durationMinutes;
  final bool accepting;
  final bool deleted;

  BookableMeetingType copyWith({
    String? scheduleId,
    String? title,
    String? location,
    int? durationMinutes,
    bool? accepting,
    bool? deleted,
  }) => BookableMeetingType(
    hostId: hostId,
    scheduleId: scheduleId ?? this.scheduleId,
    title: title ?? this.title,
    location: location ?? this.location,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    accepting: accepting ?? this.accepting,
    deleted: deleted ?? this.deleted,
  );
}

/// One meeting of the host that holds time: its slot, and a requested new slot while a reschedule is pending.
typedef HeldSlot = ({({DateTime start, DateTime end}) current, ({DateTime start, DateTime end})? pending});

/// The state that `reserve_meeting_slot` decides on, folded from the events of the meeting type, its schedule, and
/// its host.
final class ReserveMeetingSlotState {
  const ReserveMeetingSlotState({
    this.meetingType,
    this.schedule,
    this.hostName,
    this.hostEmail,
    this.calendarFailed = false,
    this.busy = const [],
    this.held = const {},
  });

  final BookableMeetingType? meetingType;

  /// The availability rules of the meeting type's schedule. Null until the schedule is created.
  final ScheduleRules? schedule;

  /// The host's name and email from `employee_registered`. Null until the host is registered.
  final String? hostName;
  final String? hostEmail;
  final bool calendarFailed;
  final List<({DateTime start, DateTime end})> busy;
  final Map<String, HeldSlot> held;

  ReserveMeetingSlotState copyWith({
    BookableMeetingType? meetingType,
    ScheduleRules? schedule,
    String? hostName,
    String? hostEmail,
    bool? calendarFailed,
    List<({DateTime start, DateTime end})>? busy,
    Map<String, HeldSlot>? held,
  }) => ReserveMeetingSlotState(
    meetingType: meetingType ?? this.meetingType,
    schedule: schedule ?? this.schedule,
    hostName: hostName ?? this.hostName,
    hostEmail: hostEmail ?? this.hostEmail,
    calendarFailed: calendarFailed ?? this.calendarFailed,
    busy: busy ?? this.busy,
    held: held ?? this.held,
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
    String? timeZone,
    List<WeeklyHoursEntry>? weeklyHours,
    Map<DateTime, List<ExceptionHoursRange>>? dateExceptions,
    int? bookingWindowDays,
    int? minimumNoticeMinutes,
    int? bufferBeforeMinutes,
    int? bufferAfterMinutes,
  }) => ScheduleRules(
    timeZone: timeZone ?? this.timeZone,
    weeklyHours: weeklyHours ?? this.weeklyHours,
    dateExceptions: dateExceptions ?? this.dateExceptions,
    bookingWindowDays: bookingWindowDays ?? this.bookingWindowDays,
    minimumNoticeMinutes: minimumNoticeMinutes ?? this.minimumNoticeMinutes,
    bufferBeforeMinutes: bufferBeforeMinutes ?? this.bufferBeforeMinutes,
    bufferAfterMinutes: bufferAfterMinutes ?? this.bufferAfterMinutes,
  );
}
