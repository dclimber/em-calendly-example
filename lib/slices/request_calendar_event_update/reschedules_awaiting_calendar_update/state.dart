import '../../../bounded_contexts/meetings/api.dart';

/// A verified reschedule of `reschedules_awaiting_calendar_update`. It is listed only once [verified] is true: the
/// calendar system confirmed the new slot is free (`new_slot_verified`). Until then the item is kept but not requested.
final class ReschedulesAwaitingCalendarUpdateState {
  const ReschedulesAwaitingCalendarUpdateState({
    required this.meetingId,
    required this.newSlotStart,
    required this.newSlotEnd,
    required this.calendarEventId,
    this.verified = false,
  });

  final MeetingId meetingId;
  final NewSlotStart newSlotStart;
  final NewSlotEnd newSlotEnd;
  final CalendarEventId calendarEventId;
  final bool verified;

  ReschedulesAwaitingCalendarUpdateState copyWith({bool? verified}) => ReschedulesAwaitingCalendarUpdateState(
    meetingId: meetingId,
    newSlotStart: newSlotStart,
    newSlotEnd: newSlotEnd,
    calendarEventId: calendarEventId,
    verified: verified ?? this.verified,
  );

  @override
  bool operator ==(Object other) =>
      other is ReschedulesAwaitingCalendarUpdateState &&
      other.meetingId == meetingId &&
      other.newSlotStart == newSlotStart &&
      other.newSlotEnd == newSlotEnd &&
      other.calendarEventId == calendarEventId &&
      other.verified == verified;

  @override
  int get hashCode => Object.hash(meetingId, newSlotStart, newSlotEnd, calendarEventId, verified);

  @override
  String toString() =>
      'ReschedulesAwaitingCalendarUpdateState(meetingId: $meetingId, newSlotStart: $newSlotStart, '
      'newSlotEnd: $newSlotEnd, calendarEventId: $calendarEventId, verified: $verified)';
}
