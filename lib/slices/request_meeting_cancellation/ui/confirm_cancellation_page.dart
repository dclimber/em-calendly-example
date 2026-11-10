import 'package:jaspr/server.dart';

import '../../../bounded_contexts/meetings/api.dart';
import '../../../platform/event_store/event_store.dart';
import '../../../ui/kit.dart';
import '../../../ui/paths.dart';

/// The facts of a meeting that the cancellation shows: its title, its current start, and its participants.
final class CancellableMeeting {
  const CancellableMeeting({required this.title, required this.currentStart, required this.participantIds});

  final String title;
  final DateTime currentStart;
  final Set<String> participantIds;
}

/// Reads the meeting, following its slot through the moves and reschedules that the meeting has had.
Future<CancellableMeeting?> cancellableMeetingFor(EventStore eventStore, String meetingId) async {
  final read = await eventStore.read([
    (
      tag: 'meetingId',
      value: meetingId,
      eventTypes: const [
        MeetingSlotReservedEvent,
        MeetingMovedInCalendarEvent,
        MeetingRescheduleRequestedEvent,
        MeetingRescheduledEvent,
        MeetingRescheduleFailedEvent,
      ],
    ),
  ]);
  String? title;
  Set<String> participantIds = {};
  DateTime? currentStart;
  DateTime? pendingStart;
  for (final stored in read.events) {
    switch (stored.event) {
      case MeetingSlotReservedEvent(:final meetingTitle, :final slotStart, :final participants):
        title = meetingTitle.value;
        participantIds = {for (final p in participants.items) p.employeeId.value};
        currentStart = slotStart.value;
      case MeetingMovedInCalendarEvent(:final newSlotStart):
        currentStart = newSlotStart.value;
      case MeetingRescheduleRequestedEvent(:final newSlotStart):
        pendingStart = newSlotStart.value;
      case MeetingRescheduledEvent():
        currentStart = pendingStart ?? currentStart;
        pendingStart = null;
      case MeetingRescheduleFailedEvent():
        pendingStart = null;
      default:
    }
  }
  if (title == null || currentStart == null) return null;
  return CancellableMeeting(title: title, currentStart: currentStart, participantIds: participantIds);
}

/// Shows the meeting and asks the participant to confirm the cancellation. The form posts to the same path.
final class ConfirmCancellationPage extends AsyncStatelessComponent {
  const ConfirmCancellationPage({
    required this.eventStore,
    required this.viewerId,
    required this.meetingId,
    super.key,
  });

  final EventStore eventStore;
  final String viewerId;
  final String meetingId;

  @override
  Future<Component> build(BuildContext context) async {
    final meeting = await cancellableMeetingFor(eventStore, meetingId);
    if (meeting == null || !meeting.participantIds.contains(viewerId)) {
      return const EmptyState('Only the participants of this meeting can change it.');
    }
    return Panel(
      title: 'Cancel meeting',
      children: [
        Facts([
          ('Meeting', Component.text(meeting.title)),
          ('Time', LocalTime(iso: meeting.currentStart.toUtc().toIso8601String())),
        ]),
        PostForm(
          action: confirmCancellation(meetingId),
          submitLabel: 'Cancel meeting',
          danger: true,
          children: const [],
        ),
      ],
    );
  }
}
