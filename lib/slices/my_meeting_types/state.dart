import '../../bounded_contexts/host_setup/api.dart';

/// The read model `my_meeting_types`: the answer to "Which meeting types have I created, are they active, and what are
/// their booking links?" for one meeting type. Its key is the meeting type id; the host id is kept so that a query can
/// find the meeting types of one host.
///
/// The location is shown with the other details of the meeting type. The booking link is set by
/// `meeting_type_created` and stays the same across edits.
final class MyMeetingType {
  const MyMeetingType({
    required this.meetingTypeId,
    required this.hostId,
    required this.meetingTitle,
    required this.durationMinutes,
    required this.meetingLocation,
    required this.bookingUrl,
    required this.active,
  });

  factory MyMeetingType.fromJson(JsonMap json) => MyMeetingType(
    meetingTypeId: MeetingTypeId(json['meetingTypeId']! as String),
    hostId: HostId(json['hostId']! as String),
    meetingTitle: MeetingTitle(json['meetingTitle']! as String),
    durationMinutes: DurationMinutes(json['durationMinutes']! as int),
    meetingLocation: MeetingLocation(json['meetingLocation']! as String),
    bookingUrl: BookingUrl(json['bookingUrl']! as String),
    active: json['active']! as bool,
  );

  final MeetingTypeId meetingTypeId;
  final HostId hostId;
  final MeetingTitle meetingTitle;
  final DurationMinutes durationMinutes;
  final MeetingLocation meetingLocation;
  final BookingUrl bookingUrl;

  /// True when created or enabled, false when disabled.
  final bool active;

  MyMeetingType withDetails({
    required MeetingTitle meetingTitle,
    required DurationMinutes durationMinutes,
    required MeetingLocation meetingLocation,
  }) => MyMeetingType(
    meetingTypeId: meetingTypeId,
    hostId: hostId,
    meetingTitle: meetingTitle,
    durationMinutes: durationMinutes,
    meetingLocation: meetingLocation,
    bookingUrl: bookingUrl,
    active: active,
  );

  MyMeetingType withActive(bool value) => MyMeetingType(
    meetingTypeId: meetingTypeId,
    hostId: hostId,
    meetingTitle: meetingTitle,
    durationMinutes: durationMinutes,
    meetingLocation: meetingLocation,
    bookingUrl: bookingUrl,
    active: value,
  );

  JsonMap toJson() => {
    'meetingTypeId': meetingTypeId.value,
    'hostId': hostId.value,
    'meetingTitle': meetingTitle.value,
    'durationMinutes': durationMinutes.value,
    'meetingLocation': meetingLocation.value,
    'bookingUrl': bookingUrl.value,
    'active': active,
  };

  @override
  bool operator ==(Object other) =>
      other is MyMeetingType &&
      other.meetingTypeId == meetingTypeId &&
      other.hostId == hostId &&
      other.meetingTitle == meetingTitle &&
      other.durationMinutes == durationMinutes &&
      other.meetingLocation == meetingLocation &&
      other.bookingUrl == bookingUrl &&
      other.active == active;

  @override
  int get hashCode =>
      Object.hash(meetingTypeId, hostId, meetingTitle, durationMinutes, meetingLocation, bookingUrl, active);

  @override
  String toString() =>
      'MyMeetingType(meetingTypeId: $meetingTypeId, hostId: $hostId, meetingTitle: $meetingTitle, '
      'durationMinutes: $durationMinutes, meetingLocation: $meetingLocation, bookingUrl: $bookingUrl, active: $active)';
}
