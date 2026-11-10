import '../../bounded_contexts/employee_directory/api.dart';
import '../../bounded_contexts/host_setup/api.dart';
import '../../bounded_contexts/meetings/api.dart';

/// The `meeting_status` of the read model. [changeInProgress] holds from a reschedule or cancellation request until
/// the change completes or fails.
enum MeetingDetailsStatus { active, changeInProgress, canceled, completed }

/// The read model `meeting_details`: one meeting, keyed by its meeting id. [status] is null until the meeting is
/// confirmed. [requestedSlotStart] and [requestedSlotEnd] hold the slot of the latest reschedule request until that
/// reschedule completes. [failureReason] is the reason of the latest failed change, shown until the next change.
final class MeetingDetails {
  const MeetingDetails({
    required this.meetingId,
    required this.meetingTypeId,
    required this.meetingTitle,
    required this.meetingLocation,
    required this.slotStart,
    required this.slotEnd,
    required this.participants,
    this.status,
    this.requestedSlotStart,
    this.requestedSlotEnd,
    this.failureReason,
    this.calendarEventId,
  });

  factory MeetingDetails.fromJson(Map<String, Object?> json) => MeetingDetails(
    meetingId: MeetingId(json['meetingId']! as String),
    meetingTypeId: MeetingTypeId(json['meetingTypeId']! as String),
    meetingTitle: MeetingTitle(json['meetingTitle']! as String),
    meetingLocation: MeetingLocation(json['meetingLocation']! as String),
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
    status: json['status'] == null ? null : MeetingDetailsStatus.values.byName(json['status']! as String),
    requestedSlotStart: json['requestedSlotStart'] == null
        ? null
        : SlotStart(DateTime.parse(json['requestedSlotStart']! as String)),
    requestedSlotEnd: json['requestedSlotEnd'] == null
        ? null
        : SlotEnd(DateTime.parse(json['requestedSlotEnd']! as String)),
    failureReason: json['failureReason'] == null ? null : FailureReason(json['failureReason']! as String),
    calendarEventId: json['calendarEventId'] == null ? null : CalendarEventId(json['calendarEventId']! as String),
  );

  final MeetingId meetingId;
  final MeetingTypeId meetingTypeId;
  final MeetingTitle meetingTitle;
  final MeetingLocation meetingLocation;
  final SlotStart slotStart;
  final SlotEnd slotEnd;
  final Participants participants;
  final MeetingDetailsStatus? status;
  final SlotStart? requestedSlotStart;
  final SlotEnd? requestedSlotEnd;
  final FailureReason? failureReason;
  final CalendarEventId? calendarEventId;

  /// The employee ids of the host and the booker: only these may see the meeting.
  Iterable<EmployeeId> get participantIds => participants.items.map((p) => p.employeeId);

  bool isParticipant(EmployeeId employeeId) => participantIds.contains(employeeId);

  /// Confirmed and not ended: the meeting holds its time, possibly with a change in progress.
  bool get isLive => status == MeetingDetailsStatus.active || status == MeetingDetailsStatus.changeInProgress;

  /// The status allows a change: active and confirmed, with no change in progress.
  bool get canChange => status == MeetingDetailsStatus.active;

  MeetingDetails copyWith({
    MeetingDetailsStatus? status,
    SlotStart? slotStart,
    SlotEnd? slotEnd,
    SlotStart? requestedSlotStart,
    SlotEnd? requestedSlotEnd,
    FailureReason? failureReason,
    CalendarEventId? calendarEventId,
    bool clearRequestedSlot = false,
    bool clearFailureReason = false,
  }) => MeetingDetails(
    meetingId: meetingId,
    meetingTypeId: meetingTypeId,
    meetingTitle: meetingTitle,
    meetingLocation: meetingLocation,
    slotStart: slotStart ?? this.slotStart,
    slotEnd: slotEnd ?? this.slotEnd,
    participants: participants,
    status: status ?? this.status,
    requestedSlotStart: clearRequestedSlot ? null : (requestedSlotStart ?? this.requestedSlotStart),
    requestedSlotEnd: clearRequestedSlot ? null : (requestedSlotEnd ?? this.requestedSlotEnd),
    failureReason: clearFailureReason ? null : (failureReason ?? this.failureReason),
    calendarEventId: calendarEventId ?? this.calendarEventId,
  );

  Map<String, Object?> toJson() => {
    'meetingId': meetingId.value,
    'meetingTypeId': meetingTypeId.value,
    'meetingTitle': meetingTitle.value,
    'meetingLocation': meetingLocation.value,
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
    'status': status?.name,
    'requestedSlotStart': requestedSlotStart?.value.toUtc().toIso8601String(),
    'requestedSlotEnd': requestedSlotEnd?.value.toUtc().toIso8601String(),
    'failureReason': failureReason?.value,
    'calendarEventId': calendarEventId?.value,
  };

  @override
  bool operator ==(Object other) =>
      other is MeetingDetails &&
      other.meetingId == meetingId &&
      other.meetingTypeId == meetingTypeId &&
      other.meetingTitle == meetingTitle &&
      other.meetingLocation == meetingLocation &&
      other.slotStart == slotStart &&
      other.slotEnd == slotEnd &&
      other.participants == participants &&
      other.status == status &&
      other.requestedSlotStart == requestedSlotStart &&
      other.requestedSlotEnd == requestedSlotEnd &&
      other.failureReason == failureReason &&
      other.calendarEventId == calendarEventId;

  @override
  int get hashCode => Object.hash(
    meetingId,
    meetingTypeId,
    meetingTitle,
    meetingLocation,
    slotStart,
    slotEnd,
    participants,
    status,
    requestedSlotStart,
    requestedSlotEnd,
    failureReason,
    calendarEventId,
  );

  @override
  String toString() =>
      'MeetingDetails(meetingId: $meetingId, meetingTypeId: $meetingTypeId, meetingTitle: $meetingTitle, '
      'meetingLocation: $meetingLocation, slotStart: $slotStart, slotEnd: $slotEnd, participants: $participants, '
      'status: $status, requestedSlotStart: $requestedSlotStart, requestedSlotEnd: $requestedSlotEnd, '
      'failureReason: $failureReason, calendarEventId: $calendarEventId)';
}
