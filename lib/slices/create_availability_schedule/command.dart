import '../../bounded_contexts/host_setup/api.dart';

/// Creates an availability schedule (`create_availability_schedule`). `schedule_id` and `host_id` are generated.
final class CreateAvailabilityScheduleCommand {
  const CreateAvailabilityScheduleCommand({
    required this.scheduleId,
    required this.hostId,
    required this.scheduleName,
    required this.timeZone,
  });

  final ScheduleId scheduleId;
  final HostId hostId;
  final ScheduleName scheduleName;
  final TimeZone timeZone;

  @override
  bool operator ==(Object other) =>
      other is CreateAvailabilityScheduleCommand &&
      other.scheduleId == scheduleId &&
      other.hostId == hostId &&
      other.scheduleName == scheduleName &&
      other.timeZone == timeZone;

  @override
  int get hashCode => Object.hash(scheduleId, hostId, scheduleName, timeZone);

  @override
  String toString() => 'CreateAvailabilityScheduleCommand($scheduleId, $hostId, $scheduleName, $timeZone)';
}
