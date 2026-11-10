import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/meetings/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/event_streaming/event_subscription.dart';
import 'handler.dart';
import 'publisher.dart';
import 'request_booking_availability_check/command.dart';
import 'reservations_awaiting_live_check/repository.dart';
import 'reservations_awaiting_live_check/state.dart';
import 'saga.dart';

/// The automation `request_booking_availability_check`: asks the calendar system whether the host is free for a held
/// slot, once per reservation.
final class RequestBookingAvailabilityCheckSlice implements VerticalSlice {
  const RequestBookingAvailabilityCheckSlice();

  @override
  String get name => 'request_booking_availability_check';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final processor =
        createSagaManager<
          ReservationAwaitingLiveCheckState,
          RequestBookingAvailabilityCheckCommand,
          NoMetadata,
          NoMetadata
        >(
          saga: bookingCheckRequesterSaga,
          actionPublisher: createRequestBookingAvailabilityCheckPublisher(services.eventStore),
        );
    final repository = ReservationsAwaitingLiveCheckRepository(services.viewStore);
    registrar.subscribe(
      EventSubscription(
        name: 'automation:request_booking_availability_check',
        eventTypes: {MeetingSlotReservedEvent, BookingAvailabilityCheckRequestedEvent},
        handle: (stored) => requestBookingAvailabilityCheckHandler(processor, repository, stored),
      ),
    );
  }
}
