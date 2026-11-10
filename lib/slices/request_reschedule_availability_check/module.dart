import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/meetings/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/event_streaming/event_subscription.dart';
import 'handler.dart';
import 'publisher.dart';
import 'request_reschedule_availability_check/command.dart';
import 'reschedules_awaiting_live_check/repository.dart';
import 'reschedules_awaiting_live_check/state.dart';
import 'saga.dart';

/// The automation `request_reschedule_availability_check`: asks the calendar system whether the host is free for a
/// requested new time, once per reschedule.
final class RequestRescheduleAvailabilityCheckSlice implements VerticalSlice {
  const RequestRescheduleAvailabilityCheckSlice();

  @override
  String get name => 'request_reschedule_availability_check';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final processor =
        createSagaManager<
          RescheduleAwaitingLiveCheckState,
          RequestRescheduleAvailabilityCheckCommand,
          NoMetadata,
          NoMetadata
        >(
          saga: rescheduleCheckRequesterSaga,
          actionPublisher: createRequestRescheduleAvailabilityCheckPublisher(services.eventStore),
        );
    final repository = ReschedulesAwaitingLiveCheckRepository(services.viewStore);
    registrar.subscribe(
      EventSubscription(
        name: 'automation:request_reschedule_availability_check',
        eventTypes: {
          MeetingRescheduleRequestedEvent,
          RescheduleAvailabilityCheckRequestedEvent,
          MeetingMovedInCalendarEvent,
          MeetingCanceledEvent,
        },
        handle: (stored) => requestRescheduleAvailabilityCheckHandler(processor, repository, stored),
      ),
    );
  }
}
