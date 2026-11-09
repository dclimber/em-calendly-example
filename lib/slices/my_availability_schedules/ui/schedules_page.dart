import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import '../../../bounded_contexts/host_setup/api.dart';
import '../../../ui/format.dart';
import '../../../ui/kit.dart';
import '../../../ui/paths.dart';
import '../service.dart';
import '../state.dart';

/// The page of the meeting host's availability schedules: each schedule with its rules and date exceptions.
final class AvailabilitySchedulesPage extends AsyncStatelessComponent {
  const AvailabilitySchedulesPage({required this.service, required this.hostId, super.key});

  final MyAvailabilitySchedulesService service;
  final HostId hostId;

  @override
  Future<Component> build(BuildContext context) async {
    final schedules = await service.schedulesOf(hostId);
    return Panel(
      children: [
        LinkButton(href: newScheduleRoute, label: 'New schedule', primary: true),
        if (schedules.isEmpty) const EmptyState('You have no availability schedules yet.'),
        for (final schedule in schedules) _ScheduleCard(schedule),
      ],
    );
  }
}

final class _ScheduleCard extends StatelessComponent {
  const _ScheduleCard(this.schedule);

  final AvailabilitySchedule schedule;

  @override
  Component build(BuildContext context) {
    final id = schedule.scheduleId.value;
    return Panel(
      title: schedule.scheduleName.value,
      children: [
        Facts([
          ('Time zone', Component.text(schedule.timeZone.value)),
          ('Weekly hours', Component.text(_weeklyHoursText(schedule))),
          ('Booking limits', Component.text(_bookingLimitsText(schedule))),
        ]),
        div(classes: 'actions', [
          LinkButton(href: weeklyHours(id), label: 'Edit weekly hours'),
          LinkButton(href: bookingLimits(id), label: 'Edit booking limits'),
          LinkButton(href: newDateException(id), label: 'Add date exception'),
        ]),
        if (schedule.dateExceptions.items.isEmpty)
          const EmptyState('No date exceptions.')
        else
          DataTable(
            headers: const ['Date', 'Hours', ''],
            rows: [
              for (final exception in schedule.dateExceptions.items)
                [
                  Component.text(isoDate(exception.exceptionDate)),
                  Component.text(_hoursText(exception.hours)),
                  div(classes: 'actions', [
                    LinkButton(
                      href: changeDateException(id, isoDate(exception.exceptionDate)),
                      label: 'Change',
                    ),
                    PostButton(
                      action: removeDateException(id, isoDate(exception.exceptionDate)),
                      label: 'Remove',
                      danger: true,
                    ),
                  ]),
                ],
            ],
          ),
      ],
    );
  }

  static String _weeklyHoursText(AvailabilitySchedule schedule) {
    if (schedule.weeklyHours.items.isEmpty) return 'No weekly hours yet';
    return schedule.weeklyHours.items.map((entry) => '${entry.weekday} ${entry.startTime}-${entry.endTime}').join(', ');
  }

  static String _hoursText(ExceptionHours hours) {
    if (hours.items.isEmpty) return 'Unavailable all day';
    return hours.items.map((range) => '${range.startTime}-${range.endTime}').join(', ');
  }

  static String _bookingLimitsText(AvailabilitySchedule schedule) {
    final window = schedule.bookingWindowDays;
    final notice = schedule.minimumNoticeMinutes;
    final before = schedule.bufferBeforeMinutes;
    final after = schedule.bufferAfterMinutes;
    if (window == null || notice == null || before == null || after == null) return 'Not set yet';
    return '${window.value} days ahead, ${notice.value} min notice, '
        '${before.value} min buffer before, ${after.value} min buffer after';
  }
}
