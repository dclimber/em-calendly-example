import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import '../../../bounded_contexts/employee_directory/api.dart';
import '../../../ui/kit.dart';
import '../../../ui/paths.dart';
import '../repository.dart';
import '../state.dart';

/// The page of one meeting. Only its participants see it: a missing document shows that the meeting is not available
/// yet, and anyone else gets an empty state. The change links show only while the meeting can change.
final class MeetingDetailsPage extends AsyncStatelessComponent {
  const MeetingDetailsPage({required this.repository, required this.meetingId, required this.viewerId, super.key});

  final MeetingDetailsRepository repository;
  final String meetingId;
  final EmployeeId viewerId;

  @override
  Future<Component> build(BuildContext context) async {
    final meeting = await repository.load(meetingId);
    if (meeting == null || meeting.status == null) {
      return const Panel(
        title: 'Meeting',
        children: [EmptyState('This meeting is not available yet.')],
      );
    }
    if (!meeting.isParticipant(viewerId)) {
      return const Panel(
        title: 'Meeting',
        children: [EmptyState('You cannot see this meeting.')],
      );
    }
    return Panel(
      title: meeting.meetingTitle.value,
      children: [
        Facts([
          ('Time', _time(meeting)),
          ('Location', Component.text(meeting.meetingLocation.value)),
          ('Status', _status(meeting.status!)),
          if (meeting.failureReason != null)
            ('Last change', Component.text('The change did not go through: ${meeting.failureReason!.value}')),
          if (meeting.calendarEventId != null) ('Calendar event', Component.text(meeting.calendarEventId!.value)),
        ]),
        DataTable(
          headers: const ['Name', 'Role'],
          rows: [
            for (final participant in meeting.participants.items)
              [Component.text(participant.name.value), Component.text(participant.role)],
          ],
        ),
        if (meeting.canChange)
          div(classes: 'actions', [
            LinkButton(href: rescheduleSlotPicker(meeting.meetingId.value), label: 'Reschedule'),
            LinkButton(href: confirmCancellation(meeting.meetingId.value), label: 'Cancel meeting'),
          ]),
      ],
    );
  }

  static Component _time(MeetingDetails meeting) => span([
    LocalTime(iso: meeting.slotStart.value.toUtc().toIso8601String()),
    Component.text(' to '),
    LocalTime(iso: meeting.slotEnd.value.toUtc().toIso8601String(), timeOnly: true),
  ]);

  static Component _status(MeetingDetailsStatus status) => switch (status) {
    MeetingDetailsStatus.active => const Badge('Active', tone: BadgeTone.good),
    MeetingDetailsStatus.changeInProgress => const Badge('Change in progress', tone: BadgeTone.warning),
    MeetingDetailsStatus.canceled => const Badge('Canceled', tone: BadgeTone.bad),
    MeetingDetailsStatus.completed => const Badge('Completed'),
  };
}
