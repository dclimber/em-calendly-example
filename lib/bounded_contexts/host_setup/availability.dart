/// The slot calculation of the model (`field_source` of `readmodel.view_available_slots.available_slots`), shared
/// by the booking page, the reschedule picker, and the deciders that revalidate a chosen slot
/// (`reserve_meeting_slot`, `request_meeting_reschedule`).
///
/// "Start from the weekly hours in the schedule's time zone, so that local hours hold across daylight-saving
/// changes. Apply date exceptions, the booking window, and minimum notice. Remove busy intervals and held slots
/// with their buffers. Cut what remains to the meeting duration. Offer nothing when the calendar connection has
/// failed."
///
/// Pure functions over plain values; callers fold the events into [AvailabilityRules], busy, and held ranges.
library;

import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'value_objects.dart';

/// A span between two instants, `start` inclusive and `end` exclusive, in UTC.
typedef TimeRange = ({DateTime start, DateTime end});

/// The availability rules of one schedule.
final class AvailabilityRules {
  const AvailabilityRules({
    this.timeZone = 'UTC',
    this.weeklyHours = const [],
    this.dateExceptions = const {},
    this.bookingWindowDays,
    this.minimumNoticeMinutes = 0,
    this.bufferBeforeMinutes = 0,
    this.bufferAfterMinutes = 0,
  });

  /// The IANA time zone of the schedule, for example `Europe/Berlin`. Weekly hours are local times in it.
  final String timeZone;

  /// Entries such as (`Monday`, `09:00`, `17:00`). Several entries per weekday are allowed.
  final List<WeeklyHoursEntry> weeklyHours;

  /// The hours of each date with an exception, keyed by the local date (`DateTime.utc(y, m, d)`). An empty list
  /// makes the whole date unavailable.
  final Map<DateTime, List<ExceptionHoursRange>> dateExceptions;

  /// How many days ahead a slot may start. Null: no limit set (then [defaultHorizon] bounds the calculation).
  final int? bookingWindowDays;
  final int minimumNoticeMinutes;
  final int bufferBeforeMinutes;
  final int bufferAfterMinutes;
}

/// How far ahead slots are calculated when the schedule sets no booking window.
const defaultHorizon = Duration(days: 60);

/// The outcome of [checkSlot], in the order the checks run.
enum SlotCheck {
  /// The slot can be booked.
  available,

  /// Another meeting of the host holds an overlapping slot (buffers included).
  held,

  /// The host's calendar connection has failed, so availability cannot be verified.
  unverified,

  /// The host's calendar reports the time as busy (buffers included).
  busy,

  /// The slot is outside the weekly hours, date exceptions, booking window, or minimum notice, or its length is
  /// not the meeting duration.
  outsideRules,
}

const _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

bool _timeZonesLoaded = false;

tz.Location _location(String name) {
  if (!_timeZonesLoaded) {
    tz_data.initializeTimeZones();
    _timeZonesLoaded = true;
  }
  // The tz database names UTC `Etc/UTC`; `tz.UTC` is the built-in location.
  return name == 'UTC' ? tz.UTC : tz.getLocation(name);
}

/// The minutes after midnight of `HH:mm`.
int _minutes(String time) {
  final parts = time.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}

/// The open ranges (UTC) of the local dates from [from] to [until], from weekly hours and date exceptions.
List<TimeRange> openRanges(AvailabilityRules rules, DateTime from, DateTime until) {
  final location = _location(rules.timeZone);
  final first = tz.TZDateTime.from(from, location);
  final last = tz.TZDateTime.from(until, location);
  final ranges = <TimeRange>[];
  for (
    var day = DateTime.utc(first.year, first.month, first.day);
    !day.isAfter(DateTime.utc(last.year, last.month, last.day));
    day = DateTime.utc(day.year, day.month, day.day + 1)
  ) {
    final hours =
        rules.dateExceptions[day] ??
        [
          for (final entry in rules.weeklyHours)
            if (entry.weekday == _weekdays[day.weekday - 1])
              ExceptionHoursRange(startTime: entry.startTime, endTime: entry.endTime),
        ];
    for (final range in hours) {
      final start = _minutes(range.startTime), end = _minutes(range.endTime);
      if (end <= start) continue;
      ranges.add((
        start: _utc(tz.TZDateTime(location, day.year, day.month, day.day, start ~/ 60, start % 60)),
        end: _utc(tz.TZDateTime(location, day.year, day.month, day.day, end ~/ 60, end % 60)),
      ));
    }
  }
  ranges.sort((a, b) => a.start.compareTo(b.start));
  return ranges;
}

/// A plain UTC `DateTime`; a `TZDateTime` never equals a `DateTime`.
DateTime _utc(DateTime d) => DateTime.fromMicrosecondsSinceEpoch(d.microsecondsSinceEpoch, isUtc: true);

bool _overlaps(TimeRange a, TimeRange b) => a.start.isBefore(b.end) && b.start.isBefore(a.end);

List<TimeRange> _withBuffers(AvailabilityRules rules, List<TimeRange> ranges) => [
  for (final r in ranges)
    (
      start: r.start.subtract(Duration(minutes: rules.bufferBeforeMinutes)),
      end: r.end.add(Duration(minutes: rules.bufferAfterMinutes)),
    ),
];

/// [ranges] minus every range of [blocked].
List<TimeRange> _subtract(List<TimeRange> ranges, List<TimeRange> blocked) {
  var free = ranges;
  for (final b in blocked) {
    free = [
      for (final r in free)
        if (!_overlaps(r, b))
          r
        else ...[
          if (r.start.isBefore(b.start)) (start: r.start, end: b.start),
          if (b.end.isBefore(r.end)) (start: b.end, end: r.end),
        ],
    ];
  }
  return free;
}

/// The earliest and the latest start of a slot that the minimum notice and the booking window allow.
(DateTime, DateTime) _startBounds(AvailabilityRules rules, DateTime now) => (
  now.toUtc().add(Duration(minutes: rules.minimumNoticeMinutes)),
  now.toUtc().add(rules.bookingWindowDays == null ? defaultHorizon : Duration(days: rules.bookingWindowDays!)),
);

/// Every slot of [duration] that can be booked, in start order.
///
/// The free time (open ranges minus busy and held ranges, each widened by the buffers) is cut into consecutive
/// slots of [duration] from the start of each free range. A slot is kept when its start respects the minimum
/// notice and the booking window. With [calendarFailed], nothing is offered.
List<TimeRange> availableSlots({
  required AvailabilityRules rules,
  required Duration duration,
  required DateTime now,
  List<TimeRange> busy = const [],
  List<TimeRange> held = const [],
  bool calendarFailed = false,
}) {
  if (calendarFailed || duration <= Duration.zero) return const [];
  final (earliest, latest) = _startBounds(rules, now);
  final free = _subtract(openRanges(rules, now, latest.add(const Duration(days: 1))), [
    ..._withBuffers(rules, busy),
    ..._withBuffers(rules, held),
  ]);
  return [
    for (final range in free)
      for (var start = range.start; !start.add(duration).isAfter(range.end); start = start.add(duration))
        if (!start.isBefore(earliest) && !start.isAfter(latest)) (start: start, end: start.add(duration)),
  ];
}

/// Whether [slot] can be booked now, checked in the order of [SlotCheck].
///
/// The slot need not start on the grid of [availableSlots]: any slot of exactly [duration] inside an open range
/// passes the rules.
SlotCheck checkSlot({
  required AvailabilityRules rules,
  required TimeRange slot,
  required Duration duration,
  required DateTime now,
  List<TimeRange> busy = const [],
  List<TimeRange> held = const [],
  bool calendarFailed = false,
}) {
  final s = (start: slot.start.toUtc(), end: slot.end.toUtc());
  if (_withBuffers(rules, held).any((h) => _overlaps(h, s))) return SlotCheck.held;
  if (calendarFailed) return SlotCheck.unverified;
  if (_withBuffers(rules, busy).any((b) => _overlaps(b, s))) return SlotCheck.busy;
  final (earliest, latest) = _startBounds(rules, now);
  final inRules =
      s.end.difference(s.start) == duration &&
      !s.start.isBefore(earliest) &&
      !s.start.isAfter(latest) &&
      openRanges(rules, s.start, s.end).any((r) => !s.start.isBefore(r.start) && !s.end.isAfter(r.end));
  return inRules ? SlotCheck.available : SlotCheck.outsideRules;
}
