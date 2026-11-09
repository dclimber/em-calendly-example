import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import '../../../bounded_contexts/host_setup/api.dart';
import '../../../platform/event_store/event_store.dart';
import '../../../ui/kit.dart';
import '../../../ui/paths.dart';
import '../errors.dart';

/// The screen `edit_booking_limits`: the four limits, prefilled from the latest `booking_limits_set`. Only the host of
/// the schedule sees the form.
final class EditBookingLimitsPage extends AsyncStatelessComponent {
  const EditBookingLimitsPage({required this.eventStore, required this.scheduleId, required this.hostId, super.key});

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
        title: 'Booking limits',
        children: [
          p([Component.text(const NotScheduleHostError().message)]),
        ],
      );
    }

    final saved = await eventStore.read([
      (tag: 'scheduleId', value: scheduleId.value, eventTypes: const [BookingLimitsSetEvent]),
    ]);
    final latest = saved.events.map((stored) => stored.event).whereType<BookingLimitsSetEvent>().lastOrNull;

    return Panel(
      title: 'Booking limits',
      children: [
        PostForm(
          action: bookingLimits(scheduleId.value),
          submitLabel: 'Save booking limits',
          children: [
            Field(
              label: 'Booking window (days)',
              input: textInput(
                'booking_window_days',
                type: 'number',
                value: latest?.bookingWindowDays.value.toString() ?? '',
              ),
            ),
            Field(
              label: 'Minimum notice (minutes)',
              input: textInput(
                'minimum_notice_minutes',
                type: 'number',
                value: latest?.minimumNoticeMinutes.value.toString() ?? '',
              ),
            ),
            Field(
              label: 'Buffer before (minutes)',
              input: textInput(
                'buffer_before_minutes',
                type: 'number',
                value: latest?.bufferBeforeMinutes.value.toString() ?? '',
              ),
            ),
            Field(
              label: 'Buffer after (minutes)',
              input: textInput(
                'buffer_after_minutes',
                type: 'number',
                value: latest?.bufferAfterMinutes.value.toString() ?? '',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
