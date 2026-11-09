import '../../bounded_contexts/host_setup/api.dart';
import '../../platform/web/http.dart';
import 'command.dart';

/// Builds the command from the form. `host_id` comes from the signed-in host, `schedule_id` from the id generator.
/// A missing name or time zone throws [FormInputError] (the framework shows it to the person).
CreateAvailabilityScheduleCommand createAvailabilityScheduleCommand(
  FormRequest request, {
  required String scheduleId,
}) => CreateAvailabilityScheduleCommand(
  scheduleId: ScheduleId(scheduleId),
  hostId: HostId(request.viewer.employeeId),
  scheduleName: ScheduleName(request.requiredField('schedule_name', label: 'Schedule name')),
  timeZone: TimeZone(request.requiredField('time_zone', label: 'Time zone')),
);
