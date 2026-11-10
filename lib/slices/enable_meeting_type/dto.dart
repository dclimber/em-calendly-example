import '../../bounded_contexts/host_setup/api.dart';
import '../../platform/web/http.dart';
import 'command.dart';

/// Builds the command from the request. The button posts no fields: `meeting_type_id` is the path parameter, and
/// `host_id` is the signed-in viewer.
EnableMeetingTypeCommand enableMeetingTypeCommand(FormRequest request) => EnableMeetingTypeCommand(
  meetingTypeId: MeetingTypeId(request.param('meetingTypeId')),
  hostId: HostId(request.viewer.employeeId),
);
