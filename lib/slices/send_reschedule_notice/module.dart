import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/meetings/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/event_streaming/event_subscription.dart';
import 'handler.dart';
import 'publisher.dart';
import 'reschedule_notices_to_send/repository.dart';
import 'reschedule_notices_to_send/state.dart';
import 'saga.dart';
import 'send_reschedule_notice/command.dart';
import 'send_reschedule_notice/service.dart';

/// The automation `send_reschedule_notice`: every participant is told the new time by email, after a completed
/// reschedule or a direct move in the calendar, once per new time.
final class SendRescheduleNoticeSlice implements VerticalSlice {
  const SendRescheduleNoticeSlice();

  @override
  String get name => 'send_reschedule_notice';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final processor =
        createSagaManager<RescheduleNoticeToSendState, SendRescheduleNoticeCommand, NoMetadata, NoMetadata>(
          saga: rescheduleNotifierSaga,
          actionPublisher: createSendRescheduleNoticePublisher(services.eventStore),
        );
    final repository = RescheduleNoticesToSendRepository(services.viewStore);
    final service = SendRescheduleNoticeService(eventStore: services.eventStore);
    registrar.subscribe(
      EventSubscription(
        name: 'automation:send_reschedule_notice',
        eventTypes: {
          MeetingSlotReservedEvent,
          MeetingRescheduleRequestedEvent,
          MeetingRescheduledEvent,
          MeetingMovedInCalendarEvent,
          RescheduleNoticeSentEvent,
        },
        handle: (stored) => sendRescheduleNoticeHandler(processor, repository, service, services, stored),
      ),
    );
  }
}
