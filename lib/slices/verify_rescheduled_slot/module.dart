import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/corporate_calendar/api.dart';
import '../../bounded_contexts/meetings/api.dart';
import '../../composition/app_services.dart';
import '../../composition/vertical_slice.dart';
import '../../platform/event_streaming/event_subscription.dart';
import 'free_answers_for_reschedules/state.dart';
import 'handler.dart';
import 'publisher.dart';
import 'record_new_slot_verified/command.dart';
import 'saga.dart';

/// The automation `verify_rescheduled_slot`: records that the host's calendar confirmed the requested new slot is free,
/// for a meeting that is rescheduling.
final class VerifyRescheduledSlotSlice implements VerticalSlice {
  const VerifyRescheduledSlotSlice();

  @override
  String get name => 'verify_rescheduled_slot';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final processor =
        createSagaManager<FreeAnswerForRescheduleState, RecordNewSlotVerifiedCommand, NoMetadata, NoMetadata>(
          saga: rescheduleFreeTranslatorSaga,
          actionPublisher: createRecordNewSlotVerifiedPublisher(services.eventStore),
        );
    registrar.subscribe(
      EventSubscription(
        name: 'automation:verify_rescheduled_slot',
        eventTypes: {HostSlotFoundFreeEvent, RescheduleAvailabilityCheckRequestedEvent},
        handle: (stored) => verifyRescheduledSlotHandler(processor, stored),
      ),
    );
  }
}
