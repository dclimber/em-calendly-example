import '../../bounded_contexts/employee_directory/api.dart';
import '../../bounded_contexts/meetings/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/view_store/materialized_view.dart';
import '../../ui/paths.dart';
import 'repository.dart';
import 'ui/meeting_details_page.dart';
import 'view.dart';

final class MeetingDetailsSlice implements VerticalSlice {
  const MeetingDetailsSlice();

  @override
  String get name => 'meeting_details';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final repository = MeetingDetailsRepository(services.viewStore);

    registrar
      ..subscribe(
        materializedViewSubscription(
          view: meetingDetailsView,
          repository: repository,
          eventTypes: const {
            MeetingSlotReservedEvent,
            MeetingConfirmedEvent,
            MeetingRescheduleRequestedEvent,
            MeetingRescheduledEvent,
            MeetingMovedInCalendarEvent,
            MeetingRescheduleFailedEvent,
            MeetingCancellationRequestedEvent,
            MeetingCanceledEvent,
            MeetingCancellationFailedEvent,
            MeetingCompletedEvent,
          },
        ),
      )
      ..page(
        meetingDetailsRoute,
        title: 'Meeting',
        builder: (request) => MeetingDetailsPage(
          repository: repository,
          meetingId: request.param('meetingId'),
          viewerId: EmployeeId(request.viewer.employeeId),
        ),
      );
  }
}
