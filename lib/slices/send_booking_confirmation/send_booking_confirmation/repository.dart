import '../../../bounded_contexts/meetings/api.dart';
import '../../../platform/event_store/consistent_event_repository.dart';
import '../../../platform/event_store/event_store.dart';
import 'command.dart';

/// The `meeting` history that the booking-confirmation decision reads.
List<EventQuery> sendBookingConfirmationQueries(MeetingId meetingId) => [
  (
    tag: 'meetingId',
    value: meetingId.value,
    eventTypes: const [
      MeetingSlotReservedEvent,
      MeetingConfirmedEvent,
      MeetingBookingFailedEvent,
      BookingConfirmationSentEvent,
    ],
  ),
];

/// Reads the `meeting` history that the decision reads, and appends the confirmation only if none of it changed.
final class SendBookingConfirmationEventRepository
    extends ConsistentEventRepository<SendBookingConfirmationCommand, MeetingsEvent> {
  SendBookingConfirmationEventRepository(super.store);

  @override
  List<EventQuery> queriesFor(SendBookingConfirmationCommand command) =>
      sendBookingConfirmationQueries(command.meetingId);
}
