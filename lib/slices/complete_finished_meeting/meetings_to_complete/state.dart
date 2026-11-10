import '../../../bounded_contexts/meetings/api.dart';

/// A meeting of `meetings_to_complete`: its current end time, while the meeting is not yet completed.
///
/// [confirmed] is false from `meeting_slot_reserved` until `meeting_confirmed`; only a confirmed item is due. The item
/// holds the end of the latest completed reschedule or direct calendar move. A reschedule that is requested but not yet
/// completed waits in [pendingSlotEnd]; it becomes [slotEnd] on `meeting_rescheduled` and is dropped on
/// `meeting_reschedule_failed`.
final class MeetingToComplete {
  const MeetingToComplete({
    required this.meetingId,
    required this.slotEnd,
    required this.confirmed,
    this.pendingSlotEnd,
  });

  factory MeetingToComplete.fromJson(Map<String, Object?> json) => MeetingToComplete(
    meetingId: MeetingId(json['meetingId']! as String),
    slotEnd: SlotEnd(DateTime.parse(json['slotEnd']! as String)),
    confirmed: json['confirmed']! as bool,
    pendingSlotEnd: json['pendingSlotEnd'] == null ? null : SlotEnd(DateTime.parse(json['pendingSlotEnd']! as String)),
  );

  final MeetingId meetingId;
  final SlotEnd slotEnd;
  final bool confirmed;

  /// The end requested by a reschedule that has not been completed or failed yet, or null.
  final SlotEnd? pendingSlotEnd;

  MeetingToComplete copyWith({
    SlotEnd? slotEnd,
    bool? confirmed,
    SlotEnd? pendingSlotEnd,
    bool clearPendingSlotEnd = false,
  }) => MeetingToComplete(
    meetingId: meetingId,
    slotEnd: slotEnd ?? this.slotEnd,
    confirmed: confirmed ?? this.confirmed,
    pendingSlotEnd: clearPendingSlotEnd ? null : (pendingSlotEnd ?? this.pendingSlotEnd),
  );

  Map<String, Object?> toJson() => {
    'meetingId': meetingId.value,
    'slotEnd': slotEnd.value.toUtc().toIso8601String(),
    'confirmed': confirmed,
    'pendingSlotEnd': pendingSlotEnd?.value.toUtc().toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      other is MeetingToComplete &&
      other.meetingId == meetingId &&
      other.slotEnd == slotEnd &&
      other.confirmed == confirmed &&
      other.pendingSlotEnd == pendingSlotEnd;

  @override
  int get hashCode => Object.hash(meetingId, slotEnd, confirmed, pendingSlotEnd);

  @override
  String toString() =>
      'MeetingToComplete(meetingId: $meetingId, slotEnd: $slotEnd, confirmed: $confirmed, '
      'pendingSlotEnd: $pendingSlotEnd)';
}
