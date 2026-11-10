import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import 'handler.dart';
import '../../ui/paths.dart';
import 'service.dart';
import 'ui/review_booking_page.dart';

final class ReserveMeetingSlotSlice implements VerticalSlice {
  const ReserveMeetingSlotSlice();

  @override
  String get name => 'reserve_meeting_slot';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final service = ReserveMeetingSlotService(eventStore: services.eventStore);

    registrar
      ..page(
        reviewBookingRoute,
        title: 'Review your booking',
        builder: (request) => ReviewBookingPage(
          meetingTypeId: request.param('meetingTypeId'),
          start: DateTime.tryParse(request.query['start'] ?? '')?.toUtc(),
          end: DateTime.tryParse(request.query['end'] ?? '')?.toUtc(),
        ),
      )
      ..form(reviewBookingRoute, (request) => reserveMeetingSlotHandler(service, services, request));
  }
}
