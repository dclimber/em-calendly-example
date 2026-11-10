import '../../bounded_contexts/host_setup/api.dart';
import '../../bounded_contexts/meetings/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/view_store/materialized_view.dart';
import '../../ui/paths.dart';
import 'repository.dart';
import 'service.dart';
import 'ui/hosted_meetings_page.dart';
import 'view.dart';

final class HostedMeetingsSlice implements VerticalSlice {
  const HostedMeetingsSlice();

  @override
  String get name => 'hosted_meetings';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final repository = HostedMeetingsRepository(services.viewStore);
    final service = HostedMeetingsService(repository: repository);

    registrar
      ..subscribe(
        materializedViewSubscription(
          view: hostedMeetingsView,
          repository: repository,
          eventTypes: const {
            MeetingSlotReservedEvent,
            MeetingConfirmedEvent,
            MeetingRescheduleRequestedEvent,
            MeetingRescheduledEvent,
            MeetingMovedInCalendarEvent,
            MeetingCanceledEvent,
            MeetingCompletedEvent,
          },
        ),
      )
      ..nav(const NavItem(label: 'Hosted meetings', path: hostedMeetingsRoute, order: 40))
      ..page(
        hostedMeetingsRoute,
        title: 'Hosted meetings',
        builder: (request) => HostedMeetingsPage(
          service: service,
          hostId: HostId(request.viewer.employeeId),
        ),
      );
  }
}
