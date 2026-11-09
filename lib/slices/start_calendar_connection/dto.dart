import '../../bounded_contexts/host_setup/api.dart';
import '../../platform/web/http.dart';
import 'command.dart';

/// Builds the command from the request. The form has no fields: `host_id` is generated from the signed-in host.
StartCalendarConnectionCommand startCalendarConnectionCommand(FormRequest request) =>
    StartCalendarConnectionCommand(hostId: HostId(request.viewer.employeeId));
