import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/meetings/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/event_streaming/event_subscription.dart';
import 'cancellation_notices_to_send/repository.dart';
import 'cancellation_notices_to_send/state.dart';
import 'handler.dart';
import 'publisher.dart';
import 'saga.dart';
import 'send_cancellation_notice/command.dart';
import 'send_cancellation_notice/service.dart';

/// The automation `send_cancellation_notice`: every participant is told by email that the meeting is canceled, after a
/// cancellation by the scheduler or a direct deletion in the calendar, once per meeting.
final class SendCancellationNoticeSlice implements VerticalSlice {
  const SendCancellationNoticeSlice();

  @override
  String get name => 'send_cancellation_notice';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final processor =
        createSagaManager<CancellationNoticeToSendState, SendCancellationNoticeCommand, NoMetadata, NoMetadata>(
          saga: cancellationNotifierSaga,
          actionPublisher: createSendCancellationNoticePublisher(services.eventStore),
        );
    final repository = CancellationNoticesToSendRepository(services.viewStore);
    final service = SendCancellationNoticeService(eventStore: services.eventStore);
    registrar.subscribe(
      EventSubscription(
        name: 'automation:send_cancellation_notice',
        eventTypes: {
          MeetingSlotReservedEvent,
          MeetingCancellationRequestedEvent,
          MeetingCanceledEvent,
          CancellationNoticeSentEvent,
        },
        handle: (stored) => sendCancellationNoticeHandler(processor, repository, service, services, stored),
      ),
    );
  }
}
