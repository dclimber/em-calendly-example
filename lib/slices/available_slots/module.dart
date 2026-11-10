import '../../bounded_contexts/employee_directory/api.dart';
import '../../bounded_contexts/host_setup/api.dart';
import '../../bounded_contexts/meetings/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/view_store/materialized_view.dart';
import '../../ui/paths.dart';
import 'repository.dart';
import 'ui/booking_page.dart';
import 'ui/reschedule_slot_picker_page.dart';
import 'view.dart';

final class AvailableSlotsSlice implements VerticalSlice {
  const AvailableSlotsSlice();

  @override
  String get name => 'available_slots';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final repository = AvailableSlotsRepository(services.viewStore);

    registrar
      ..subscribe(
        materializedViewSubscription(
          view: availableSlotsView,
          repository: repository,
          eventTypes: const {
            EmployeeRegisteredEvent,
            AvailabilityScheduleCreatedEvent,
            WeeklyHoursSetEvent,
            DateExceptionAddedEvent,
            DateExceptionChangedEvent,
            DateExceptionRemovedEvent,
            BookingLimitsSetEvent,
            CalendarConnectedEvent,
            CalendarConnectionFailedEvent,
            HostBusyTimesRecordedEvent,
            MeetingTypeCreatedEvent,
            MeetingTypeEditedEvent,
            MeetingTypeDisabledEvent,
            MeetingTypeEnabledEvent,
            MeetingTypeDeletedEvent,
            MeetingSlotReservedEvent,
            MeetingBookingFailedEvent,
            MeetingRescheduleRequestedEvent,
            MeetingRescheduledEvent,
            MeetingMovedInCalendarEvent,
            MeetingRescheduleFailedEvent,
            MeetingCanceledEvent,
          },
        ),
      )
      ..page(
        bookingPageRoute,
        title: 'Book a meeting',
        builder: (request) => BookingPage(
          repository: repository,
          meetingTypeId: request.param('meetingTypeId'),
          now: services.clock.now(),
        ),
      )
      ..page(
        rescheduleSlotPickerRoute,
        title: 'Choose a new time',
        builder: (request) => RescheduleSlotPickerPage(
          repository: repository,
          meetingId: request.param('meetingId'),
          viewerId: request.viewer.employeeId,
          now: services.clock.now(),
        ),
      );
  }
}
