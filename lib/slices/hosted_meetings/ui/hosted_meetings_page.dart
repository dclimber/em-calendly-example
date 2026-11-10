import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import '../../../bounded_contexts/host_setup/api.dart';
import '../../../bounded_contexts/meetings/api.dart';
import '../../../ui/kit.dart';
import '../../../ui/paths.dart';
import '../service.dart';
import '../state.dart';

/// The page of the meetings booked through the host's links, earliest first. Each row links to the meeting details.
/// Only meetings of the viewer are listed.
final class HostedMeetingsPage extends AsyncStatelessComponent {
  const HostedMeetingsPage({required this.service, required this.hostId, super.key});

  final HostedMeetingsService service;
  final HostId hostId;

  @override
  Future<Component> build(BuildContext context) async {
    final meetings = await service.meetingsHostedBy(hostId);
    if (meetings.isEmpty) {
      return const Panel(
        title: 'Hosted meetings',
        children: [EmptyState('No one has booked a meeting through your links yet.')],
      );
    }
    return Panel(
      title: 'Hosted meetings',
      children: [
        DataTable(
          headers: const ['Meeting', 'Time', 'Booker', 'Status', ''],
          rows: [
            for (final meeting in meetings)
              [
                Component.text(meeting.meetingTitle.value),
                _time(meeting),
                Component.text(meeting.booker?.name.value ?? ''),
                _status(meeting.meetingStatus!),
                LinkButton(href: meetingDetails(meeting.meetingId.value), label: 'Open'),
              ],
          ],
        ),
      ],
    );
  }

  static Component _time(HostedMeeting meeting) => span([
    LocalTime(iso: meeting.slotStart.value.toUtc().toIso8601String()),
    Component.text(' to '),
    LocalTime(iso: meeting.slotEnd.value.toUtc().toIso8601String(), timeOnly: true),
  ]);

  static Component _status(MeetingStatus status) {
    if (status == HostedMeetingStatus.canceled) {
      return const Badge('Canceled', tone: BadgeTone.bad);
    }
    if (status == HostedMeetingStatus.completed) {
      return const Badge('Completed');
    }
    return const Badge('Active', tone: BadgeTone.good);
  }
}
