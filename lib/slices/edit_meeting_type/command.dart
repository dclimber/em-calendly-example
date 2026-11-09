import '../../bounded_contexts/host_setup/api.dart';

/// Edits a meeting type (`edit_meeting_type`). `host_id` is the signed-in host; the decider refuses an edit by anyone
/// else (see the gap report: the model's command has no host field).
final class EditMeetingTypeCommand {
  const EditMeetingTypeCommand({
    required this.meetingTypeId,
    required this.hostId,
    required this.meetingTitle,
    required this.durationMinutes,
    required this.meetingLocation,
    required this.scheduleId,
    this.meetingDescription,
  });

  final MeetingTypeId meetingTypeId;
  final HostId hostId;
  final MeetingTitle meetingTitle;
  final DurationMinutes durationMinutes;
  final MeetingLocation meetingLocation;
  final ScheduleId scheduleId;
  final MeetingDescription? meetingDescription;

  @override
  bool operator ==(Object other) =>
      other is EditMeetingTypeCommand &&
      other.meetingTypeId == meetingTypeId &&
      other.hostId == hostId &&
      other.meetingTitle == meetingTitle &&
      other.durationMinutes == durationMinutes &&
      other.meetingLocation == meetingLocation &&
      other.scheduleId == scheduleId &&
      other.meetingDescription == meetingDescription;

  @override
  int get hashCode => Object.hash(
    meetingTypeId,
    hostId,
    meetingTitle,
    durationMinutes,
    meetingLocation,
    scheduleId,
    meetingDescription,
  );

  @override
  String toString() => 'EditMeetingTypeCommand($meetingTypeId, $hostId, $meetingTitle)';
}
