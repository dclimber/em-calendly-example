import '../../../bounded_contexts/meetings/api.dart';

/// A meeting of `meetings_to_complete`: its current end time, while the meeting is not yet completed.
///
/// [confirmed] is false from `meeting_slot_reserved` until `meeting_confirmed`; only a confirmed item is due. The item
/// holds the end of the latest reschedule request or direct calendar move.
final class MeetingToComplete {
  const MeetingToComplete({required this.meetingId, required this.slotEnd, required this.confirmed});

  factory MeetingToComplete.fromJson(Map<String, Object?> json) => MeetingToComplete(
    meetingId: MeetingId(json['meetingId']! as String),
    slotEnd: SlotEnd(DateTime.parse(json['slotEnd']! as String)),
    confirmed: json['confirmed']! as bool,
  );

  final MeetingId meetingId;
  final SlotEnd slotEnd;
  final bool confirmed;

  MeetingToComplete copyWith({SlotEnd? slotEnd, bool? confirmed}) => MeetingToComplete(
    meetingId: meetingId,
    slotEnd: slotEnd ?? this.slotEnd,
    confirmed: confirmed ?? this.confirmed,
  );

  Map<String, Object?> toJson() => {
    'meetingId': meetingId.value,
    'slotEnd': slotEnd.value.toUtc().toIso8601String(),
    'confirmed': confirmed,
  };

  @override
  bool operator ==(Object other) =>
      other is MeetingToComplete &&
      other.meetingId == meetingId &&
      other.slotEnd == slotEnd &&
      other.confirmed == confirmed;

  @override
  int get hashCode => Object.hash(meetingId, slotEnd, confirmed);

  @override
  String toString() => 'MeetingToComplete(meetingId: $meetingId, slotEnd: $slotEnd, confirmed: $confirmed)';
}
