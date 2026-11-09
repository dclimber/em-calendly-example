import '../../bounded_contexts/host_setup/api.dart';

/// Sets the booking window, the minimum notice, and the buffers of an availability schedule (`set_booking_limits`).
///
/// `host_id` is not a field of the model's command. It is the signed-in host, which the decider checks against the
/// schedule's host (the model states no rule for this; see the gap report in the slice notes).
final class SetBookingLimitsCommand {
  const SetBookingLimitsCommand({
    required this.scheduleId,
    required this.hostId,
    required this.bookingWindowDays,
    required this.minimumNoticeMinutes,
    required this.bufferBeforeMinutes,
    required this.bufferAfterMinutes,
  });

  final ScheduleId scheduleId;
  final HostId hostId;
  final BookingWindowDays bookingWindowDays;
  final MinimumNoticeMinutes minimumNoticeMinutes;
  final BufferBeforeMinutes bufferBeforeMinutes;
  final BufferAfterMinutes bufferAfterMinutes;

  @override
  bool operator ==(Object other) =>
      other is SetBookingLimitsCommand &&
      other.scheduleId == scheduleId &&
      other.hostId == hostId &&
      other.bookingWindowDays == bookingWindowDays &&
      other.minimumNoticeMinutes == minimumNoticeMinutes &&
      other.bufferBeforeMinutes == bufferBeforeMinutes &&
      other.bufferAfterMinutes == bufferAfterMinutes;

  @override
  int get hashCode =>
      Object.hash(scheduleId, hostId, bookingWindowDays, minimumNoticeMinutes, bufferBeforeMinutes, bufferAfterMinutes);

  @override
  String toString() =>
      'SetBookingLimitsCommand($scheduleId, $hostId, $bookingWindowDays, $minimumNoticeMinutes, $bufferBeforeMinutes, $bufferAfterMinutes)';
}
