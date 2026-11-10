import '../../../bounded_contexts/meetings/api.dart';
import '../../../platform/event_store/consistent_event_repository.dart';
import '../../../platform/event_store/event_store.dart';
import 'command.dart';

/// Reads every `meeting` event that the confirmation decision folds, and appends the confirmation only if none of
/// them changed.
final class ConfirmMeetingEventRepository extends ConsistentEventRepository<ConfirmMeetingCommand, MeetingsEvent> {
  ConfirmMeetingEventRepository(super.store);

  @override
  List<EventQuery> queriesFor(ConfirmMeetingCommand command) => [
    (
      tag: 'meetingId',
      value: command.meetingId.value,
      eventTypes: const [
        MeetingSlotReservedEvent,
        BookingAvailabilityCheckRequestedEvent,
        BookingSlotVerifiedEvent,
        CalendarEventRequestedEvent,
        MeetingConfirmedEvent,
        MeetingBookingFailedEvent,
      ],
    ),
  ];
}
