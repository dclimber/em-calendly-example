import '../../bounded_contexts/meetings/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/view_store/materialized_view.dart';
import '../../ui/paths.dart';
import 'repository.dart';
import 'service.dart';
import 'ui/my_booked_meetings_page.dart';
import 'view.dart';

final class MyBookedMeetingsSlice implements VerticalSlice {
  const MyBookedMeetingsSlice();

  @override
  String get name => 'my_booked_meetings';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final repository = MyBookedMeetingsRepository(services.viewStore);
    final service = MyBookedMeetingsService(repository: repository);

    registrar
      ..subscribe(
        materializedViewSubscription(
          view: myBookedMeetingsView,
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
      ..nav(const NavItem(label: 'My bookings', path: bookedMeetingsRoute, order: 50))
      ..page(
        bookedMeetingsRoute,
        title: 'My bookings',
        builder: (request) => MyBookedMeetingsPage(
          service: service,
          bookerId: BookerId(request.viewer.employeeId),
        ),
      );
  }
}
