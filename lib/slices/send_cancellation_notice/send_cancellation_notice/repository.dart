import '../../../bounded_contexts/meetings/api.dart';
import '../../../platform/event_store/consistent_event_repository.dart';
import '../../../platform/event_store/event_store.dart';
import 'command.dart';

/// The `meeting` history that the cancellation-notice decision reads: every lifecycle event, and the notices sent.
List<EventQuery> sendCancellationNoticeQueries(MeetingId meetingId) => [
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
      CancellationNoticeSentEvent,
    ],
  ),
];

/// Reads the `meeting` history that the decision reads, and appends the notice only if none of it changed.
final class SendCancellationNoticeEventRepository
    extends ConsistentEventRepository<SendCancellationNoticeCommand, MeetingsEvent> {
  SendCancellationNoticeEventRepository(super.store);

  @override
  List<EventQuery> queriesFor(SendCancellationNoticeCommand command) =>
      sendCancellationNoticeQueries(command.meetingId);
}
