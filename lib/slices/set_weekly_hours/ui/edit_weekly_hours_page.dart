import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import '../../../bounded_contexts/host_setup/api.dart';
import '../../../platform/event_store/event_store.dart';
import '../../../ui/kit.dart';
import '../../../ui/paths.dart';
import '../errors.dart';

const _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

/// The screen `edit_weekly_hours`: one start and one end per weekday, prefilled from the latest `weekly_hours_set`.
/// Only the host of the schedule sees the form.
final class EditWeeklyHoursPage extends AsyncStatelessComponent {
  const EditWeeklyHoursPage({required this.eventStore, required this.scheduleId, required this.hostId, super.key});

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
    if (owner == null || owner.hostId != hostId) {
      return Panel(
        title: 'Weekly hours',
        children: [
          p([Component.text(const NotScheduleHostError().message)]),
        ],
      );
    }

    final saved = await eventStore.read([
      (tag: 'scheduleId', value: scheduleId.value, eventTypes: const [WeeklyHoursSetEvent]),
    ]);
    final latest = saved.events.map((stored) => stored.event).whereType<WeeklyHoursSetEvent>().lastOrNull;
    final entries = latest?.weeklyHours.items ?? const <WeeklyHoursEntry>[];

    return Panel(
      title: 'Weekly hours',
      children: [
        PostForm(
          action: weeklyHours(scheduleId.value),
          submitLabel: 'Save weekly hours',
          children: [
            for (final day in _days)
              div(classes: 'field', [
                input(name: 'weekday', value: day, attributes: {'type': 'hidden'}),
                Field(
                  label: '$day from',
                  input: textInput('start_time', type: 'time', value: _timeFor(entries, day, start: true)),
                ),
                Field(
                  label: '$day until',
                  input: textInput('end_time', type: 'time', value: _timeFor(entries, day, start: false)),
                ),
              ]),
          ],
        ),
      ],
    );
  }
}

String _timeFor(List<WeeklyHoursEntry> entries, String day, {required bool start}) {
  for (final entry in entries) {
    if (entry.weekday == day) return start ? entry.startTime : entry.endTime;
  }
  return '';
}
