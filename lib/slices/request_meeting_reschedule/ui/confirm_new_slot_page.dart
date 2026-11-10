import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import '../../../bounded_contexts/meetings/api.dart';
import '../../../platform/event_store/event_store.dart';
import '../../../ui/kit.dart';
import '../../../ui/paths.dart';

/// The facts of a meeting that the confirmation shows: its title, its current slot, and whether the viewer is a
/// participant.
final class ReschedulingMeeting {
  const ReschedulingMeeting({
    required this.title,
    required this.currentStart,
    required this.participantIds,
  });

  final String title;
  final DateTime currentStart;
  final Set<String> participantIds;
}

/// Reads the meeting, following its slot through the moves and reschedules that the meeting has had.
Future<ReschedulingMeeting?> reschedulingMeetingFor(EventStore eventStore, String meetingId) async {
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
  return ReschedulingMeeting(title: title, currentStart: currentStart, participantIds: participantIds);
}

/// Shows the new slot, the current slot, and asks the participant to confirm the change. The form posts the new slot
/// back as hidden fields.
final class ConfirmNewSlotPage extends AsyncStatelessComponent {
  const ConfirmNewSlotPage({
    required this.eventStore,
    required this.viewerId,
    required this.meetingId,
    required this.start,
    required this.end,
    super.key,
  });

  final EventStore eventStore;
  final String viewerId;
  final String meetingId;
  final DateTime? start;
  final DateTime? end;

  @override
  Future<Component> build(BuildContext context) async {
    final start = this.start;
    final end = this.end;
    if (start == null || end == null) {
      return const EmptyState('This slot is not valid. Please choose another slot.');
    }
    final meeting = await reschedulingMeetingFor(eventStore, meetingId);
    if (meeting == null || !meeting.participantIds.contains(viewerId)) {
      return const EmptyState('Only the participants of this meeting can change it.');
    }
    return Panel(
      title: 'Confirm your new time',
      children: [
        Facts([
          ('Meeting', Component.text(meeting.title)),
          ('Current time', LocalTime(iso: meeting.currentStart.toUtc().toIso8601String())),
          ('New time', LocalTime(iso: start.toUtc().toIso8601String())),
          ('New ends', LocalTime(iso: end.toUtc().toIso8601String())),
        ]),
        PostForm(
          action: confirmNewSlot(meetingId, start, end),
          submitLabel: 'Confirm new time',
          children: [
            input(type: InputType.hidden, name: 'start', value: start.toUtc().toIso8601String()),
            input(type: InputType.hidden, name: 'end', value: end.toUtc().toIso8601String()),
          ],
        ),
      ],
    );
  }
}
