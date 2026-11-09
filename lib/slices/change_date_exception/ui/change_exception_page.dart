import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import '../../../bounded_contexts/host_setup/api.dart';
import '../../../platform/event_store/event_store.dart';
import '../../../platform/web/http.dart';
import '../../../ui/kit.dart';
import '../../../ui/paths.dart';
import '../dto.dart';
import '../errors.dart';

/// The rows of the form. A schedule with more ranges than this shows all of them, so that no range is lost on save.
const _minimumRows = 3;

/// The screen `change_exception`: the date and its hour rows, prefilled from the latest `date_exception_added` or
/// `date_exception_changed` of the date, unless a `date_exception_removed` came later. Only the host of the schedule
/// sees the form.
final class ChangeExceptionPage extends AsyncStatelessComponent {
  const ChangeExceptionPage({
    required this.eventStore,
    required this.scheduleId,
    required this.hostId,
    required this.date,
    super.key,
  });

  final EventStore eventStore;
  final ScheduleId scheduleId;
  final HostId hostId;

  /// The date of the path, `yyyy-MM-dd`.
  final String date;

  @override
  Future<Component> build(BuildContext context) async {
    final ExceptionDate exceptionDate;
    try {
      exceptionDate = exceptionDateFromText(date);
    } on FormInputError catch (error) {
      return Panel(
        title: 'Change a date exception',
        children: [
          p([Component.text(error.message)]),
        ],
      );
    }

    final history = await eventStore.read([
      (
        tag: 'scheduleId',
        value: scheduleId.value,
        eventTypes: const [
          AvailabilityScheduleCreatedEvent,
          DateExceptionAddedEvent,
          DateExceptionChangedEvent,
          DateExceptionRemovedEvent,
        ],
      ),
    ]);
    final owner = history.events
        .map((stored) => stored.event)
        .whereType<AvailabilityScheduleCreatedEvent>()
        .firstOrNull;
    if (owner == null) {
      return Panel(
        title: 'Change a date exception',
        children: [
          p([Component.text(const ScheduleNotDefinedError().message)]),
        ],
      );
    }
    if (owner.hostId != hostId) {
      return Panel(
        title: 'Change a date exception',
        children: [
          p([Component.text(const NotScheduleHostError().message)]),
        ],
      );
    }

    final current = _currentHours(history.events.map((stored) => stored.event), exceptionDate);
    final ranges = current?.items ?? const <ExceptionHoursRange>[];
    final rows = ranges.length > _minimumRows ? ranges.length : _minimumRows;

    return Panel(
      title: 'Change a date exception',
      children: [
        if (current == null) p([Component.text('This date has no exception. Saving creates one.')]),
        PostForm(
          action: changeDateException(scheduleId.value, date),
          submitLabel: 'Save date exception',
          children: [
            Field(
              label: 'Date',
              input: input(
                name: 'date',
                value: date,
                attributes: {'type': 'date', 'readonly': ''},
              ),
            ),
            for (var i = 0; i < rows; i++)
              div(classes: 'field', [
                Field(
                  label: 'Hours ${i + 1} from',
                  input: textInput(
                    'start_time',
                    type: 'time',
                    value: i < ranges.length ? ranges[i].startTime : '',
                  ),
                ),
                Field(
                  label: 'Hours ${i + 1} until',
                  input: textInput(
                    'end_time',
                    type: 'time',
                    value: i < ranges.length ? ranges[i].endTime : '',
                  ),
                ),
              ]),
          ],
        ),
      ],
    );
  }
}

/// The hours of [date] after the events, in append order: the last added or changed hours, or null when the last
/// event of the date is a removal, or when the date never had an exception.
ExceptionHours? _currentHours(Iterable<DomainEvent> events, ExceptionDate date) {
  ExceptionHours? hours;
  for (final event in events) {
    switch (event) {
      case DateExceptionAddedEvent(:final exceptionDate, :final exceptionHours) when exceptionDate == date:
        hours = exceptionHours;
      case DateExceptionChangedEvent(:final exceptionDate, :final exceptionHours) when exceptionDate == date:
        hours = exceptionHours;
      case DateExceptionRemovedEvent(:final exceptionDate) when exceptionDate == date:
        hours = null;
    }
  }
  return hours;
}
