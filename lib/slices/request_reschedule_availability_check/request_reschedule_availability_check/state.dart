import '../../../bounded_contexts/meetings/api.dart';

/// The new slot of a reschedule whose live check was requested.
typedef CheckedSlot = ({NewSlotStart start, NewSlotEnd end});

/// The meeting as the decider folds it: its lifecycle state, and the new slot whose live check was already requested.
final class RequestRescheduleAvailabilityCheckState {
  const RequestRescheduleAvailabilityCheckState({this.lifecycle, this.checkedSlot});

  /// Null before the meeting is reserved.
  final MeetingLifecycleState? lifecycle;

  /// Null until a check is requested. A repeat of the same new slot is refused; a different new slot is checked.
  final CheckedSlot? checkedSlot;

  @override
  bool operator ==(Object other) =>
      other is RequestRescheduleAvailabilityCheckState &&
      other.lifecycle == lifecycle &&
      other.checkedSlot == checkedSlot;

  @override
  int get hashCode => Object.hash(lifecycle, checkedSlot);

  @override
  String toString() => 'RequestRescheduleAvailabilityCheckState(lifecycle: $lifecycle, checkedSlot: $checkedSlot)';
}
