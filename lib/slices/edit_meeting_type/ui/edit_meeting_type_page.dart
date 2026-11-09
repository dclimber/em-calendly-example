import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import '../../../bounded_contexts/host_setup/api.dart';
import '../../../platform/event_store/event_store.dart';
import '../../../ui/kit.dart';
import '../../../ui/paths.dart';
import '../errors.dart';
import '../prefill.dart';

/// The screen `edit_meeting_type`: the form prefilled from the latest values. Only the host sees the form.
final class EditMeetingTypePage extends AsyncStatelessComponent {
  const EditMeetingTypePage({required this.eventStore, required this.meetingTypeId, required this.hostId, super.key});

  final EventStore eventStore;
  final MeetingTypeId meetingTypeId;
  final HostId hostId;

  @override
  Future<Component> build(BuildContext context) async {
    final details = await meetingTypeDetailsFor(eventStore, meetingTypeId);
    if (details == null || details.hostId != hostId) {
      return Panel(
        title: 'Edit meeting type',
        children: [
          p([Component.text(const NotMeetingTypeHostError().message)]),
        ],
      );
    }
    final schedules = await scheduleOptionsFor(eventStore, hostId);
    return Panel(
      title: 'Edit meeting type',
      children: [
        PostForm(
          action: editMeetingType(meetingTypeId.value),
          submitLabel: 'Save meeting type',
          children: [
            Field(
              label: 'Meeting title',
              input: textInput('meeting_title', value: details.meetingTitle.value, required: true),
            ),
            Field(
              label: 'Description',
              hint: 'Optional. Shown to bookers.',
              input: textArea('meeting_description', value: details.meetingDescription?.value),
            ),
            Field(
              label: 'Duration in minutes',
              input: textInput(
                'duration_minutes',
                type: 'number',
                min: 1,
                value: details.durationMinutes.value.toString(),
                required: true,
              ),
            ),
            Field(
              label: 'Meeting location',
              input: textInput('meeting_location', value: details.meetingLocation.value, required: true),
            ),
            Field(
              label: 'Availability schedule',
              input: selectInput(
                'schedule_id',
                schedules,
                selected: details.scheduleId.value,
                required: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
