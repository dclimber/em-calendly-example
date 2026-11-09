import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../composition/vertical_slice.dart';
import '../platform/corporate_calendar/calendar_bridge.dart';
import '../platform/corporate_calendar/mock_corporate_calendar.dart';
import '../platform/web/http.dart';
import 'format.dart';
import 'kit.dart';
import 'paths.dart';

/// `/dev/calendar`: plays the people who use the corporate calendar, while [MockCorporateCalendar] stands in for it.
void registerDevCalendarConsole(SliceRegistrar registrar, MockCorporateCalendar calendar, CalendarBridge bridge) {
  registrar
    ..nav(const NavItem(label: 'Dev calendar', path: devCalendarRoute, order: 1000))
    ..page(devCalendarRoute, title: 'Mock corporate calendar', builder: (_) => DevCalendarConsole(calendar))
    ..form('$devCalendarRoute/busy', (request) async {
      final email = request.requiredField('email', label: 'Email');
      final from = _utc(request.requiredField('from', label: 'From'));
      final until = _utc(request.requiredField('until', label: 'Until'));
      if (!until.isAfter(from)) return errorRedirect(devCalendarRoute, 'The end must be after the start.');
      calendar.addBusyBlock(email, (from: from, until: until));
      return noticeRedirect(devCalendarRoute, 'Busy block added.');
    })
    ..form('$devCalendarRoute/busy/clear', (request) async {
      calendar.clearBusyBlocks(request.requiredField('email'));
      return noticeRedirect(devCalendarRoute, 'Busy blocks cleared.');
    })
    ..form('$devCalendarRoute/failures', (request) async {
      final operation = MockCalendarOperation.values.byName(request.requiredField('operation'));
      final code = request.field('code');
      if (code == null) {
        calendar.clearFailure(operation);
        return noticeRedirect(devCalendarRoute, '${operation.name} works again.');
      }
      calendar.failOperation(operation, code);
      return noticeRedirect(devCalendarRoute, '${operation.name} now fails with $code.');
    })
    ..form('$devCalendarRoute/events/<id>/move', (request) async {
      final start = _utc(request.requiredField('start', label: 'Start'));
      final end = _utc(request.requiredField('end', label: 'End'));
      calendar.moveDirectly(request.param('id'), start, end);
      return noticeRedirect(devCalendarRoute, 'Event moved in the calendar.');
    })
    ..form('$devCalendarRoute/events/<id>/delete', (request) async {
      calendar.deleteDirectly(request.param('id'));
      return noticeRedirect(devCalendarRoute, 'Event deleted in the calendar.');
    })
    ..form('$devCalendarRoute/sync', (request) async {
      await bridge.reportFreeBusy();
      await bridge.reportDirectChanges();
      return noticeRedirect(devCalendarRoute, 'Free/busy data and direct changes reported.');
    });
}

/// A `datetime-local` value, read as UTC.
DateTime _utc(String value) {
  final parsed = DateTime.tryParse(value) ?? (throw FormInputError('$value is not a date and time.'));
  return DateTime.utc(parsed.year, parsed.month, parsed.day, parsed.hour, parsed.minute);
}

String _local(DateTime d) => '${isoDate(d)}T${formatTime(d)}';

class DevCalendarConsole extends StatelessComponent {
  const DevCalendarConsole(this.calendar, {super.key});

  final MockCorporateCalendar calendar;

  @override
  Component build(BuildContext context) {
    final failures = calendar.failures;
    final busy = calendar.busyBlocks;
    return div(classes: 'stack', [
      p([
        .text(
          'No Google credentials are configured, so this in-memory calendar answers the scheduler. '
          'Times on this page are UTC. The calendar forgets everything when the server restarts.',
        ),
      ]),
      PostButton(action: '$devCalendarRoute/sync', label: 'Report free/busy and direct changes now'),
      Panel(
        title: 'Failures',
        children: [
          DataTable(
            headers: const ['Operation', 'State', ''],
            rows: [
              for (final operation in MockCalendarOperation.values)
                [
                  .text(operation.name),
                  failures[operation] == null
                      ? const Badge('works', tone: BadgeTone.good)
                      : Badge('fails: ${failures[operation]}', tone: BadgeTone.bad),
                  failures[operation] == null
                      ? PostButton(
                          action: '$devCalendarRoute/failures',
                          label: 'Make it fail',
                          danger: true,
                          hidden: {'operation': operation.name, 'code': '${operation.name}_failed'},
                        )
                      : PostButton(
                          action: '$devCalendarRoute/failures',
                          label: 'Make it work',
                          hidden: {'operation': operation.name},
                        ),
                ],
            ],
          ),
        ],
      ),
      Panel(
        title: 'Busy blocks',
        children: [
          if (busy.isEmpty) const EmptyState('Nobody has entered busy time.'),
          for (final MapEntry(key: email, value: blocks) in busy.entries) ...[
            h3([.text(email)]),
            ul([
              for (final b in blocks) li([.text('${formatDateTime(b.from)} – ${formatDateTime(b.until)}')]),
            ]),
            PostButton(action: '$devCalendarRoute/busy/clear', label: 'Clear', hidden: {'email': email}),
          ],
          PostForm(
            action: '$devCalendarRoute/busy',
            submitLabel: 'Add busy block',
            children: [
              Field(
                label: 'Email',
                input: textInput('email', type: 'email', required: true),
              ),
              Field(
                label: 'From (UTC)',
                input: textInput('from', type: 'datetime-local', required: true),
              ),
              Field(
                label: 'Until (UTC)',
                input: textInput('until', type: 'datetime-local', required: true),
              ),
            ],
          ),
        ],
      ),
      Panel(
        title: 'Meeting events',
        children: [
          if (calendar.events.isEmpty) const EmptyState('The scheduler has created no events.'),
          for (final event in calendar.events)
            div(classes: 'panel inner', [
              h3([.text('${event.details.title} (${event.id})')]),
              Facts([
                ('When', .text('${formatDateTime(event.start)} – ${formatDateTime(event.end)}')),
                ('Organizer', .text(event.organizerEmail)),
                ('Attendees', .text(event.details.attendeeEmails.join(', '))),
                ('State', event.removed ? const Badge('deleted', tone: BadgeTone.bad) : const Badge('active')),
              ]),
              if (!event.removed) ...[
                PostForm(
                  action: '$devCalendarRoute/events/${event.id}/move',
                  submitLabel: 'Move in the calendar',
                  children: [
                    Field(
                      label: 'Start (UTC)',
                      input: textInput('start', type: 'datetime-local', value: _local(event.start), required: true),
                    ),
                    Field(
                      label: 'End (UTC)',
                      input: textInput('end', type: 'datetime-local', value: _local(event.end), required: true),
                    ),
                  ],
                ),
                PostButton(
                  action: '$devCalendarRoute/events/${event.id}/delete',
                  label: 'Delete in the calendar',
                  danger: true,
                ),
              ],
            ]),
        ],
      ),
    ]);
  }
}
