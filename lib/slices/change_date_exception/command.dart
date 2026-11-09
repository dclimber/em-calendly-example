import '../../bounded_contexts/host_setup/api.dart';

/// Changes the hours of a date exception of an availability schedule (`change_date_exception`).
///
/// `host_id` is not a field of the model's command. It is the signed-in host, which the decider checks against the
/// schedule's host (the model states no rule for this; see the gap report in the slice notes).
final class ChangeDateExceptionCommand {
  const ChangeDateExceptionCommand({
    required this.scheduleId,
    required this.hostId,
    required this.exceptionDate,
    required this.exceptionHours,
  });

  final ScheduleId scheduleId;
  final HostId hostId;
  final ExceptionDate exceptionDate;
  final ExceptionHours exceptionHours;

  @override
  bool operator ==(Object other) =>
      other is ChangeDateExceptionCommand &&
      other.scheduleId == scheduleId &&
      other.hostId == hostId &&
      other.exceptionDate == exceptionDate &&
      other.exceptionHours == exceptionHours;

  @override
  int get hashCode => Object.hash(scheduleId, hostId, exceptionDate, exceptionHours);

  @override
  String toString() => 'ChangeDateExceptionCommand($scheduleId, $hostId, $exceptionDate, $exceptionHours)';
}
