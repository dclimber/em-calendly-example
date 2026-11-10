import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/corporate_calendar/api.dart';
import '../../bounded_contexts/meetings/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/event_streaming/event_subscription.dart';
import 'free_answers_for_bookings/state.dart';
import 'handler.dart';
import 'publisher.dart';
import 'record_booking_slot_verified/command.dart';
import 'saga.dart';

/// The automation `verify_booked_slot`: records that the host's calendar confirmed the booked slot is free, for a
/// meeting that is still pending_calendar.
final class VerifyBookedSlotSlice implements VerticalSlice {
  const VerifyBookedSlotSlice();

  @override
  String get name => 'verify_booked_slot';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final processor =
        createSagaManager<FreeAnswerForBookingState, RecordBookingSlotVerifiedCommand, NoMetadata, NoMetadata>(
          saga: bookingFreeTranslatorSaga,
          actionPublisher: createRecordBookingSlotVerifiedPublisher(services.eventStore),
        );
    registrar.subscribe(
      EventSubscription(
        name: 'automation:verify_booked_slot',
        eventTypes: {HostSlotFoundFreeEvent, BookingAvailabilityCheckRequestedEvent},
        handle: (stored) => verifyBookedSlotHandler(processor, stored),
      ),
    );
  }
}
