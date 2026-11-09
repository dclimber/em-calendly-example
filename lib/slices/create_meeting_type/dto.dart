import '../../bounded_contexts/host_setup/api.dart';
import '../../platform/web/http.dart';
import 'command.dart';
import 'errors.dart';

/// Builds the command from the form. `host_id` comes from the signed-in host; `meeting_type_id` and `booking_url`
/// come from the caller. A missing title, duration, location, or schedule throws [FormInputError] (the framework shows
/// it to the person).
CreateMeetingTypeCommand createMeetingTypeCommand(
  FormRequest request, {
  required String meetingTypeId,
  required String bookingUrl,
}) {
  final scheduleId = request.field('schedule_id');
  if (scheduleId == null) throw FormInputError(const MeetingTypeScheduleMissingError().message);
  final description = request.field('meeting_description');
  return CreateMeetingTypeCommand(
    meetingTypeId: MeetingTypeId(meetingTypeId),
    hostId: HostId(request.viewer.employeeId),
    meetingTitle: MeetingTitle(request.requiredField('meeting_title', label: 'Meeting title')),
    durationMinutes: DurationMinutes(_wholeMinutes(request)),
    meetingLocation: MeetingLocation(request.requiredField('meeting_location', label: 'Meeting location')),
    scheduleId: ScheduleId(scheduleId),
    bookingUrl: BookingUrl(bookingUrl),
    meetingDescription: description == null ? null : MeetingDescription(description),
  );
}

int _wholeMinutes(FormRequest request) {
  final raw = request.requiredField('duration_minutes', label: 'Duration in minutes');
  return int.tryParse(raw) ?? (throw const FormInputError('Duration in minutes must be a whole number.'));
}
