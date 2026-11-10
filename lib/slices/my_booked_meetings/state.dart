import '../../bounded_contexts/employee_directory/api.dart';
import '../../bounded_contexts/host_setup/api.dart';
import '../../bounded_contexts/meetings/api.dart';

/// The `meeting_status` values of the read model: active once confirmed, then canceled or completed.
abstract final class BookedMeetingStatus {
  static final active = MeetingStatus('active');
  static final canceled = MeetingStatus('canceled');
  static final completed = MeetingStatus('completed');
}

/// The read model `my_booked_meetings`: one meeting that the employee booked with a colleague. Its key is the meeting
/// id, and it keeps the booker id so that the page lists only the meetings of the viewer.
///
/// [meetingStatus] is null until the meeting is confirmed; such a document is not listed. [requestedSlotStart] and
/// [requestedSlotEnd] hold the slot of the latest reschedule request, which takes effect only when the reschedule is
/// completed.
final class BookedMeeting {
  const BookedMeeting({
    required this.meetingId,
    required this.bookerId,
    required this.meetingTitle,
    required this.slotStart,
    required this.slotEnd,
    required this.participants,
    this.meetingStatus,
    this.requestedSlotStart,
    this.requestedSlotEnd,
  });

  factory BookedMeeting.fromJson(Map<String, Object?> json) => BookedMeeting(
    meetingId: MeetingId(json['meetingId']! as String),
    bookerId: BookerId(json['bookerId']! as String),
    meetingTitle: MeetingTitle(json['meetingTitle']! as String),
    slotStart: SlotStart(DateTime.parse(json['slotStart']! as String)),
    slotEnd: SlotEnd(DateTime.parse(json['slotEnd']! as String)),
    participants: Participants([
      for (final m in (json['participants']! as List<Object?>).cast<Map<String, Object?>>())
        Participant(
          employeeId: EmployeeId(m['employeeId']! as String),
          name: EmployeeName(m['name']! as String),
          email: EmployeeEmail(m['email']! as String),
          role: m['role']! as String,
        ),
    ]),
    meetingStatus: json['meetingStatus'] == null ? null : MeetingStatus(json['meetingStatus']! as String),
    requestedSlotStart: json['requestedSlotStart'] == null
        ? null
        : SlotStart(DateTime.parse(json['requestedSlotStart']! as String)),
    requestedSlotEnd: json['requestedSlotEnd'] == null
        ? null
        : SlotEnd(DateTime.parse(json['requestedSlotEnd']! as String)),
  );

  final MeetingId meetingId;
  final BookerId bookerId;
  final MeetingTitle meetingTitle;
  final SlotStart slotStart;
  final SlotEnd slotEnd;
  final Participants participants;
  final MeetingStatus? meetingStatus;
  final SlotStart? requestedSlotStart;
  final SlotEnd? requestedSlotEnd;

  bool get isConfirmed => meetingStatus != null;

  /// The participant with the role `host`, or null if the meeting has none.
  Participant? get host {
    for (final participant in participants.items) {
      if (participant.role == 'host') return participant;
    }
    return null;
  }

  /// Confirmation: the meeting is active.
  BookedMeeting confirmed() => _copy(meetingStatus: BookedMeetingStatus.active);

  /// The meeting ends as canceled or completed. A meeting that is not confirmed is unchanged.
  BookedMeeting ended(MeetingStatus status) => isConfirmed ? _copy(meetingStatus: status) : this;

  /// The slot of a reschedule request, held until the reschedule is completed.
  BookedMeeting withRequestedSlot(SlotStart start, SlotEnd end) =>
      _copy(requestedSlotStart: start, requestedSlotEnd: end);

  /// A completed reschedule takes the requested slot. Without a request it changes nothing.
  BookedMeeting rescheduled() {
    final start = requestedSlotStart;
    final end = requestedSlotEnd;
    if (start == null || end == null) return this;
    return _copy(slotStart: start, slotEnd: end, clearRequestedSlot: true);
  }

  /// A direct calendar move takes the new slot and releases any requested slot.
  BookedMeeting movedTo(SlotStart start, SlotEnd end) =>
      _copy(slotStart: start, slotEnd: end, clearRequestedSlot: true);

  BookedMeeting _copy({
    SlotStart? slotStart,
    SlotEnd? slotEnd,
    MeetingStatus? meetingStatus,
    SlotStart? requestedSlotStart,
    SlotEnd? requestedSlotEnd,
    bool clearRequestedSlot = false,
  }) => BookedMeeting(
    meetingId: meetingId,
    bookerId: bookerId,
    meetingTitle: meetingTitle,
    slotStart: slotStart ?? this.slotStart,
    slotEnd: slotEnd ?? this.slotEnd,
    participants: participants,
    meetingStatus: meetingStatus ?? this.meetingStatus,
    requestedSlotStart: clearRequestedSlot ? null : (requestedSlotStart ?? this.requestedSlotStart),
    requestedSlotEnd: clearRequestedSlot ? null : (requestedSlotEnd ?? this.requestedSlotEnd),
  );

  Map<String, Object?> toJson() => {
    'meetingId': meetingId.value,
    'bookerId': bookerId.value,
    'meetingTitle': meetingTitle.value,
    'slotStart': slotStart.value.toUtc().toIso8601String(),
    'slotEnd': slotEnd.value.toUtc().toIso8601String(),
    'participants': [
      for (final p in participants.items)
        <String, Object?>{
          'employeeId': p.employeeId.value,
          'name': p.name.value,
          'email': p.email.value,
          'role': p.role,
        },
    ],
    'meetingStatus': meetingStatus?.value,
    'requestedSlotStart': requestedSlotStart?.value.toUtc().toIso8601String(),
    'requestedSlotEnd': requestedSlotEnd?.value.toUtc().toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      other is BookedMeeting &&
      other.meetingId == meetingId &&
      other.bookerId == bookerId &&
      other.meetingTitle == meetingTitle &&
      other.slotStart == slotStart &&
      other.slotEnd == slotEnd &&
      other.participants == participants &&
      other.meetingStatus == meetingStatus &&
      other.requestedSlotStart == requestedSlotStart &&
      other.requestedSlotEnd == requestedSlotEnd;

  @override
  int get hashCode => Object.hash(
    meetingId,
    bookerId,
    meetingTitle,
    slotStart,
    slotEnd,
    participants,
    meetingStatus,
    requestedSlotStart,
    requestedSlotEnd,
  );

  @override
  String toString() =>
      'BookedMeeting(meetingId: $meetingId, bookerId: $bookerId, meetingTitle: $meetingTitle, slotStart: $slotStart, '
      'slotEnd: $slotEnd, participants: $participants, meetingStatus: $meetingStatus, '
      'requestedSlotStart: $requestedSlotStart, requestedSlotEnd: $requestedSlotEnd)';
}
