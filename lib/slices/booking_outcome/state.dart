import '../../bounded_contexts/host_setup/api.dart';
import '../../bounded_contexts/meetings/api.dart';

/// The `meeting_status` values of the read model: pending after the reservation, then confirmed or failed.
abstract final class BookingStatus {
  static final pending = MeetingStatus('pending');
  static final confirmed = MeetingStatus('confirmed');
  static final failed = MeetingStatus('failed');
}

/// The read model `booking_outcome`: the answer to "Was my booking confirmed, and if not, why?" for one meeting.
/// Its key is the meeting id. The booker id is kept so that only the booker sees the outcome. The meeting type id and
/// the location are kept so that the page can link back to the booking and show where the meeting is.
final class BookingOutcome {
  const BookingOutcome({
    required this.meetingId,
    required this.bookerId,
    required this.meetingTypeId,
    required this.meetingTitle,
    required this.meetingLocation,
    required this.slotStart,
    required this.slotEnd,
    required this.meetingStatus,
    this.failureReason,
  });

  factory BookingOutcome.fromJson(Map<String, Object?> json) => BookingOutcome(
    meetingId: MeetingId(json['meetingId']! as String),
    bookerId: BookerId(json['bookerId']! as String),
    meetingTypeId: MeetingTypeId(json['meetingTypeId']! as String),
    meetingTitle: MeetingTitle(json['meetingTitle']! as String),
    meetingLocation: MeetingLocation(json['meetingLocation']! as String),
    slotStart: SlotStart(DateTime.parse(json['slotStart']! as String)),
    slotEnd: SlotEnd(DateTime.parse(json['slotEnd']! as String)),
    meetingStatus: MeetingStatus(json['meetingStatus']! as String),
    failureReason: json['failureReason'] == null ? null : FailureReason(json['failureReason']! as String),
  );

  final MeetingId meetingId;
  final BookerId bookerId;
  final MeetingTypeId meetingTypeId;
  final MeetingTitle meetingTitle;
  final MeetingLocation meetingLocation;
  final SlotStart slotStart;
  final SlotEnd slotEnd;
  final MeetingStatus meetingStatus;

  /// The reason the booking failed. Null unless [meetingStatus] is failed.
  final FailureReason? failureReason;

  BookingOutcome withStatus(MeetingStatus status, {FailureReason? failure}) => BookingOutcome(
    meetingId: meetingId,
    bookerId: bookerId,
    meetingTypeId: meetingTypeId,
    meetingTitle: meetingTitle,
    meetingLocation: meetingLocation,
    slotStart: slotStart,
    slotEnd: slotEnd,
    meetingStatus: status,
    failureReason: failure,
  );

  Map<String, Object?> toJson() => {
    'meetingId': meetingId.value,
    'bookerId': bookerId.value,
    'meetingTypeId': meetingTypeId.value,
    'meetingTitle': meetingTitle.value,
    'meetingLocation': meetingLocation.value,
    'slotStart': slotStart.value.toUtc().toIso8601String(),
    'slotEnd': slotEnd.value.toUtc().toIso8601String(),
    'meetingStatus': meetingStatus.value,
    'failureReason': failureReason?.value,
  };

  @override
  bool operator ==(Object other) =>
      other is BookingOutcome &&
      other.meetingId == meetingId &&
      other.bookerId == bookerId &&
      other.meetingTypeId == meetingTypeId &&
      other.meetingTitle == meetingTitle &&
      other.meetingLocation == meetingLocation &&
      other.slotStart == slotStart &&
      other.slotEnd == slotEnd &&
      other.meetingStatus == meetingStatus &&
      other.failureReason == failureReason;

  @override
  int get hashCode => Object.hash(
    meetingId,
    bookerId,
    meetingTypeId,
    meetingTitle,
    meetingLocation,
    slotStart,
    slotEnd,
    meetingStatus,
    failureReason,
  );

  @override
  String toString() =>
      'BookingOutcome(meetingId: $meetingId, bookerId: $bookerId, meetingTypeId: $meetingTypeId, '
      'meetingTitle: $meetingTitle, meetingLocation: $meetingLocation, slotStart: $slotStart, slotEnd: $slotEnd, '
      'meetingStatus: $meetingStatus, failureReason: $failureReason)';
}
