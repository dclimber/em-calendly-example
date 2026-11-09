import 'package:shelf/shelf.dart';

import '../../platform/time/clock.dart';
import '../../platform/web/http.dart';
import '../../ui/paths.dart';
import 'dto.dart';
import 'service.dart';

/// Handles `new_availability_schedule`'s form post: creates the schedule, then returns to the schedules page.
Future<Response> createAvailabilityScheduleHandler(
  CreateAvailabilityScheduleService service,
  IdGenerator ids,
  FormRequest request,
) async {
  await service.handle(createAvailabilityScheduleCommand(request, scheduleId: ids.newId()));
  return noticeRedirect(schedulesRoute, 'Creating your availability schedule.');
}
