import '../../bounded_contexts/host_setup/api.dart';

/// Creates a meeting type (`create_meeting_type`). `meeting_type_id`, `host_id`, and `booking_url` are generated.
final class CreateMeetingTypeCommand {
  const CreateMeetingTypeCommand({
    required this.meetingTypeId,
    required this.hostId,
    required this.meetingTitle,
    required this.durationMinutes,
    required this.meetingLocation,
    required this.scheduleId,
    required this.bookingUrl,
    this.meetingDescription,
  });

  final MeetingTypeId meetingTypeId;
  final HostId hostId;
  final MeetingTitle meetingTitle;
  final DurationMinutes durationMinutes;
  final MeetingLocation meetingLocation;
  final ScheduleId scheduleId;
  final BookingUrl bookingUrl;
  final MeetingDescription? meetingDescription;

  @override
  bool operator ==(Object other) =>
      other is CreateMeetingTypeCommand &&
      other.meetingTypeId == meetingTypeId &&
      other.hostId == hostId &&
      other.meetingTitle == meetingTitle &&
      other.durationMinutes == durationMinutes &&
      other.meetingLocation == meetingLocation &&
      other.scheduleId == scheduleId &&
      other.bookingUrl == bookingUrl &&
      other.meetingDescription == meetingDescription;

  @override
  int get hashCode => Object.hash(
    meetingTypeId,
    hostId,
    meetingTitle,
    durationMinutes,
    meetingLocation,
    scheduleId,
    bookingUrl,
    meetingDescription,
  );

  @override
  String toString() =>
      'CreateMeetingTypeCommand($meetingTypeId, $hostId, $meetingTitle, $durationMinutes, $meetingLocation, '
      '$scheduleId, $bookingUrl, $meetingDescription)';
}
