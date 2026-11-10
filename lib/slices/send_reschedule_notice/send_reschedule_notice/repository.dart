import '../../../bounded_contexts/meetings/api.dart';
import '../../../platform/event_store/consistent_event_repository.dart';
import '../../../platform/event_store/event_store.dart';
import 'command.dart';

/// The `meeting` history that the reschedule-notice decision reads: every lifecycle event, and the notices sent.
List<EventQuery> sendRescheduleNoticeQueries(MeetingId meetingId) => [
  (
    tag: 'meetingId',
    value: meetingId.value,
    eventTypes: const [
      MeetingSlotReservedEvent,
      MeetingConfirmedEvent,
      MeetingBookingFailedEvent,
      MeetingRescheduleRequestedEvent,
      MeetingRescheduledEvent,
      MeetingRescheduleFailedEvent,
      MeetingMovedInCalendarEvent,
      MeetingCancellationRequestedEvent,
      MeetingCancellationFailedEvent,
      MeetingCanceledEvent,
      MeetingCompletedEvent,
      RescheduleNoticeSentEvent,
    ],
  ),
];

/// Reads the `meeting` history that the decision reads, and appends the notice only if none of it changed.
final class SendRescheduleNoticeEventRepository
    extends ConsistentEventRepository<SendRescheduleNoticeCommand, MeetingsEvent> {
  SendRescheduleNoticeEventRepository(super.store);

  @override
  List<EventQuery> queriesFor(SendRescheduleNoticeCommand command) => sendRescheduleNoticeQueries(command.meetingId);
}
