import '../../bounded_contexts/host_setup/api.dart';
import '../../platform/web/http.dart';
import 'command.dart';

/// Builds the command from the form. `meeting_type_id` comes from the path; `host_id` from the signed-in host. A missing
/// title, duration, location, or schedule throws [FormInputError] (the framework shows it to the person).
EditMeetingTypeCommand editMeetingTypeCommand(FormRequest request) {
  final scheduleId = request.field('schedule_id');
  if (scheduleId == null) throw const FormInputError('Choose an availability schedule for this meeting type.');
  final description = request.field('meeting_description');
  return EditMeetingTypeCommand(
    meetingTypeId: MeetingTypeId(request.param('meetingTypeId')),
    hostId: HostId(request.viewer.employeeId),
    meetingTitle: MeetingTitle(request.requiredField('meeting_title', label: 'Meeting title')),
    durationMinutes: DurationMinutes(_wholeMinutes(request)),
    meetingLocation: MeetingLocation(request.requiredField('meeting_location', label: 'Meeting location')),
    scheduleId: ScheduleId(scheduleId),
    meetingDescription: description == null || description.isEmpty ? null : MeetingDescription(description),
  );
}

int _wholeMinutes(FormRequest request) {
  final raw = request.requiredField('duration_minutes', label: 'Duration in minutes');
  return int.tryParse(raw) ?? (throw const FormInputError('Duration in minutes must be a whole number.'));
}
