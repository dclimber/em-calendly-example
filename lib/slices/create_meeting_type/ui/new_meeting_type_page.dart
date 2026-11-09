import 'package:jaspr/server.dart';

import '../../../bounded_contexts/host_setup/api.dart';
import '../../../platform/event_store/event_store.dart';
import '../../../ui/kit.dart';
import '../../../ui/paths.dart';
import '../schedule_options.dart';

/// The form of `new_meeting_type`. Without an availability schedule, it links to creating one instead.
final class NewMeetingTypePage extends AsyncStatelessComponent {
  const NewMeetingTypePage({required this.eventStore, required this.hostId, super.key});

  final EventStore eventStore;
  final HostId hostId;

  @override
  Future<Component> build(BuildContext context) async {
    final schedules = await scheduleOptionsFor(eventStore, hostId);
    if (schedules.isEmpty) {
      return Panel(
        title: 'New meeting type',
        children: [
          const EmptyState('Create an availability schedule before you create a meeting type.'),
          LinkButton(href: newScheduleRoute, label: 'New schedule', primary: true),
        ],
      );
    }
    return Panel(
      title: 'New meeting type',
      children: [
        PostForm(
          action: meetingTypesRoute,
          submitLabel: 'Create meeting type',
          children: [
            Field(
              label: 'Meeting title',
              input: textInput('meeting_title', placeholder: '30-minute consultation', required: true),
            ),
            Field(
              label: 'Description',
              hint: 'Optional. Shown to bookers.',
              input: textArea('meeting_description'),
            ),
            Field(
              label: 'Duration in minutes',
              input: textInput('duration_minutes', type: 'number', min: 1, required: true),
            ),
            Field(label: 'Meeting location', input: textInput('meeting_location', required: true)),
            Field(
              label: 'Availability schedule',
              input: selectInput('schedule_id', schedules, selected: schedules.first.$1, required: true),
            ),
          ],
        ),
      ],
    );
  }
}
