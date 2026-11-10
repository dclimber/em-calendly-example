import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/meetings/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/event_streaming/event_subscription.dart';
import 'confirmations_to_send/repository.dart';
import 'confirmations_to_send/state.dart';
import 'handler.dart';
import 'publisher.dart';
import 'saga.dart';
import 'send_booking_confirmation/command.dart';
import 'send_booking_confirmation/service.dart';

/// The automation `send_booking_confirmation`: both participants receive a confirmation email once the meeting is
/// confirmed, once per meeting.
final class SendBookingConfirmationSlice implements VerticalSlice {
  const SendBookingConfirmationSlice();

  @override
  String get name => 'send_booking_confirmation';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final processor =
        createSagaManager<ConfirmationToSendState, SendBookingConfirmationCommand, NoMetadata, NoMetadata>(
          saga: confirmationSenderSaga,
          actionPublisher: createSendBookingConfirmationPublisher(services.eventStore),
        );
    final repository = ConfirmationsToSendRepository(services.viewStore);
    final service = SendBookingConfirmationService(eventStore: services.eventStore);
    registrar.subscribe(
      EventSubscription(
        name: 'automation:send_booking_confirmation',
        eventTypes: {MeetingSlotReservedEvent, MeetingConfirmedEvent, BookingConfirmationSentEvent},
        handle: (stored) => sendBookingConfirmationHandler(processor, repository, service, services, stored),
      ),
    );
  }
}
