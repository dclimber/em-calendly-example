import 'package:fmodel/fmodel.dart';

import '../../platform/event_store/event_store.dart';
import 'record_booking_slot_verified/command.dart';
import 'record_booking_slot_verified/service.dart';

/// Publishes `record_booking_slot_verified` commands by handling each one on the `meeting` aggregate.
///
/// The publisher lets the decider's sealed error propagate. The handler catches it, because a repeated answer is the
/// expected outcome of a redelivered event.
ActionPublisher<RecordBookingSlotVerifiedCommand, NoMetadata, NoMetadata> createRecordBookingSlotVerifiedPublisher(
  EventStore eventStore,
) {
  final service = RecordBookingSlotVerifiedService(eventStore: eventStore);

  Future<void> record(RecordBookingSlotVerifiedCommand command) => service.handle(command);

  return createActionPublisher(
    publish: (actions) async* {
      await for (final command in actions) {
        await record(command);
        yield command;
      }
    },
    publishWithMetadata: (actions) async* {
      await for (final (command, metadata) in actions) {
        await record(command);
        yield (command, metadata);
      }
    },
  );
}
