import '../../bounded_contexts/host_setup/api.dart';

/// Removes the exception of one date from an availability schedule (`remove_date_exception`).
///
/// `host_id` is not a field of the model's command. It is the signed-in host, which the decider checks against the
/// schedule's host (the model states no rule for this; the decider refuses a caller who is not the host).
final class RemoveDateExceptionCommand {
  const RemoveDateExceptionCommand({required this.scheduleId, required this.hostId, required this.exceptionDate});

  final ScheduleId scheduleId;
  final HostId hostId;
  final ExceptionDate exceptionDate;

  @override
  bool operator ==(Object other) =>
      other is RemoveDateExceptionCommand &&
      other.scheduleId == scheduleId &&
      other.hostId == hostId &&
      other.exceptionDate == exceptionDate;

  @override
  int get hashCode => Object.hash(scheduleId, hostId, exceptionDate);

  @override
  String toString() => 'RemoveDateExceptionCommand($scheduleId, $hostId, $exceptionDate)';
}
