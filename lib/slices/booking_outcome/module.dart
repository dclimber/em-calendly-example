import '../../bounded_contexts/meetings/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/view_store/materialized_view.dart';
import '../../ui/paths.dart';
import 'repository.dart';
import 'service.dart';
import 'ui/booking_result_page.dart';
import 'view.dart';

final class BookingOutcomeSlice implements VerticalSlice {
  const BookingOutcomeSlice();

  @override
  String get name => 'booking_outcome';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final repository = BookingOutcomeRepository(services.viewStore);
    final service = BookingOutcomeService(repository: repository);

    registrar
      ..subscribe(
        materializedViewSubscription(
          view: bookingOutcomeView,
          repository: repository,
          eventTypes: const {MeetingSlotReservedEvent, MeetingConfirmedEvent, MeetingBookingFailedEvent},
        ),
      )
      ..page(
        bookingResultRoute,
        title: 'Your booking',
        builder: (request) => BookingResultPage(
          service: service,
          meetingId: MeetingId(request.param('meetingId')),
          viewerId: request.viewer.employeeId,
        ),
      );
  }
}
