import '../../bounded_contexts/host_setup/api.dart';
import '../../platform/web/http.dart';
import 'command.dart';

/// Builds the command from the form. Each field is a whole number. A missing or non-numeric value is refused as form
/// input, with the field's label.
SetBookingLimitsCommand setBookingLimitsCommand(FormRequest request) => SetBookingLimitsCommand(
  scheduleId: ScheduleId(request.param('scheduleId')),
  hostId: HostId(request.viewer.employeeId),
  bookingWindowDays: BookingWindowDays(_wholeNumber(request, 'booking_window_days', 'Booking window (days)')),
  minimumNoticeMinutes: MinimumNoticeMinutes(
    _wholeNumber(request, 'minimum_notice_minutes', 'Minimum notice (minutes)'),
  ),
  bufferBeforeMinutes: BufferBeforeMinutes(_wholeNumber(request, 'buffer_before_minutes', 'Buffer before (minutes)')),
  bufferAfterMinutes: BufferAfterMinutes(_wholeNumber(request, 'buffer_after_minutes', 'Buffer after (minutes)')),
);

int _wholeNumber(FormRequest request, String name, String label) {
  final value = int.tryParse(request.requiredField(name, label: label));
  if (value == null) throw FormInputError('$label must be a whole number.');
  return value;
}
