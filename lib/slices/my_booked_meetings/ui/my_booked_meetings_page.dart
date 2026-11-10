import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import '../../../bounded_contexts/meetings/api.dart';
import '../../../ui/kit.dart';
import '../../../ui/paths.dart';
import '../service.dart';
import '../state.dart';

/// The page of the meetings the viewer booked with colleagues, earliest first. Each row links to the meeting details.
/// Only meetings of the viewer are listed.
final class MyBookedMeetingsPage extends AsyncStatelessComponent {
  const MyBookedMeetingsPage({required this.service, required this.bookerId, super.key});

  final MyBookedMeetingsService service;
  final BookerId bookerId;

  @override
  Future<Component> build(BuildContext context) async {
    final meetings = await service.meetingsBookedBy(bookerId);
    if (meetings.isEmpty) {
      return const Panel(
        title: 'My bookings',
        children: [EmptyState('You have not booked any meetings yet.')],
      );
    }
    return Panel(
      title: 'My bookings',
      children: [
        DataTable(
          headers: const ['Meeting', 'Time', 'Host', 'Status', ''],
          rows: [
            for (final meeting in meetings)
              [
                Component.text(meeting.meetingTitle.value),
                _time(meeting),
                Component.text(meeting.host?.name.value ?? ''),
                _status(meeting.meetingStatus!),
                LinkButton(href: meetingDetails(meeting.meetingId.value), label: 'Open'),
              ],
          ],
        ),
      ],
    );
  }

  static Component _time(BookedMeeting meeting) => span([
    LocalTime(iso: meeting.slotStart.value.toUtc().toIso8601String()),
    Component.text(' to '),
    LocalTime(iso: meeting.slotEnd.value.toUtc().toIso8601String(), timeOnly: true),
  ]);

  static Component _status(MeetingStatus status) {
    if (status == BookedMeetingStatus.canceled) {
      return const Badge('Canceled', tone: BadgeTone.bad);
    }
    if (status == BookedMeetingStatus.completed) {
      return const Badge('Completed');
    }
    return const Badge('Active', tone: BadgeTone.good);
  }
}
