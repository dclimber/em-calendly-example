import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import '../../../bounded_contexts/host_setup/api.dart';
import '../../../platform/event_store/event_store.dart';
import '../../../ui/kit.dart';
import '../../../ui/paths.dart';
import '../errors.dart';

/// Number of hour rows of the form. Empty rows mean no hours for the date.
const _hourRows = 3;

/// The screen `add_exception`: one date and up to three hour ranges, posted to the date exceptions route. Only the
/// host of the schedule sees the form.
final class AddExceptionPage extends AsyncStatelessComponent {
  const AddExceptionPage({required this.eventStore, required this.scheduleId, required this.hostId, super.key});

  final EventStore eventStore;
  final ScheduleId scheduleId;
  final HostId hostId;

  @override
  Future<Component> build(BuildContext context) async {
    final created = await eventStore.read([
      (tag: 'scheduleId', value: scheduleId.value, eventTypes: const [AvailabilityScheduleCreatedEvent]),
    ]);
    final owner = created.events
        .map((stored) => stored.event)
        .whereType<AvailabilityScheduleCreatedEvent>()
        .firstOrNull;
    if (owner == null) {
      return Panel(
        title: 'Add a date exception',
        children: [
          p([Component.text(const ScheduleNotDefinedError().message)]),
        ],
      );
    }
    if (owner.hostId != hostId) {
      return Panel(
        title: 'Add a date exception',
        children: [
          p([Component.text(const NotScheduleHostError().message)]),
        ],
      );
    }

    return Panel(
      title: 'Add a date exception',
      children: [
        PostForm(
          action: dateExceptionsAction(scheduleId.value),
          submitLabel: 'Add date exception',
          children: [
            Field(
              label: 'Date',
              input: textInput('date', type: 'date', required: true),
            ),
            for (var row = 1; row <= _hourRows; row++) ...[
              Field(
                label: 'Hours $row from',
                hint: row == 1 ? 'Leave all hours empty to make the whole date unavailable.' : null,
                input: textInput('start_time', type: 'time'),
              ),
              Field(
                label: 'Hours $row until',
                input: textInput('end_time', type: 'time'),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
