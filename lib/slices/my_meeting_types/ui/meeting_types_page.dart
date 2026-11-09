import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import '../../../bounded_contexts/host_setup/api.dart';
import '../../../ui/kit.dart';
import '../../../ui/paths.dart';
import '../service.dart';
import '../state.dart';

/// The page of the meeting host's meeting types: each with its duration, location, status, booking link, and actions.
final class MeetingTypesPage extends AsyncStatelessComponent {
  const MeetingTypesPage({required this.service, required this.hostId, super.key});

  final MyMeetingTypesService service;
  final HostId hostId;

  @override
  Future<Component> build(BuildContext context) async {
    final meetingTypes = await service.meetingTypesOf(hostId);
    return Panel(
      children: [
        LinkButton(href: newMeetingTypeRoute, label: 'New meeting type', primary: true),
        if (meetingTypes.isEmpty)
          const EmptyState('You have no meeting types yet.')
        else
          DataTable(
            headers: const ['Meeting type', 'Duration', 'Location', 'Status', 'Booking link', ''],
            rows: [for (final meetingType in meetingTypes) _row(meetingType)],
          ),
      ],
    );
  }

  static List<Component> _row(MyMeetingType meetingType) {
    final id = meetingType.meetingTypeId.value;
    final url = meetingType.bookingUrl.value;
    return [
      Component.text(meetingType.meetingTitle.value),
      Component.text('${meetingType.durationMinutes.value} min'),
      Component.text(meetingType.meetingLocation.value),
      Badge(
        meetingType.active ? 'Active' : 'Disabled',
        tone: meetingType.active ? BadgeTone.good : BadgeTone.neutral,
      ),
      a(href: url, [Component.text(url)]),
      div(classes: 'actions', [
        LinkButton(href: editMeetingType(id), label: 'Edit'),
        if (meetingType.active)
          PostButton(action: disableMeetingType(id), label: 'Disable')
        else
          PostButton(action: enableMeetingType(id), label: 'Enable'),
        PostButton(action: deleteMeetingType(id), label: 'Delete', danger: true),
      ]),
    ];
  }
}
