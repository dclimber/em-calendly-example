import 'package:logging/logging.dart';

import '../../bounded_contexts/corporate_calendar/api.dart';
import '../../bounded_contexts/employee_directory/api.dart';
import '../../bounded_contexts/host_setup/api.dart';
import '../../bounded_contexts/meetings/api.dart';
import '../event_store/event_store.dart';
import '../event_streaming/event_subscription.dart';
import '../jobs/job_scheduler.dart';
import '../time/clock.dart';
import '../view_store/view_state_store.dart';
import 'corporate_calendar.dart';

/// The corporate calendar system's side of the model.
///
/// The model treats the corporate calendar as an external system: the scheduler records requests (for example
/// `calendar_event_requested`), and the calendar answers with the events of the external `corporate_calendar`
/// context (for example `calendar_event_created`). This bridge plays that system. It calls the
/// [CorporateCalendar] port for each request, appends the answer, reports free/busy data of connected hosts, and
/// reports direct moves and deletions of meeting events. The translation slices turn the answers into facts of
/// the scheduler.
final class CalendarBridge {
  CalendarBridge({
    required EventStore eventStore,
    required ViewStateStore viewStore,
    required CorporateCalendar calendar,
    required Clock clock,
    this.freeBusyHorizon = const Duration(days: 90),
  }) : _store = eventStore,
       _views = viewStore,
       _calendar = calendar,
       _clock = clock;

  final EventStore _store;
  final ViewStateStore _views;
  final CorporateCalendar _calendar;
  final Clock _clock;
  final Duration freeBusyHorizon;
  final _log = Logger('calendar_bridge');

  static const _hostsView = 'calendar_bridge:hosts';
  static const _eventsView = 'calendar_bridge:events';

  EventSubscription get subscription => EventSubscription(
    name: 'integration:corporate_calendar',
    eventTypes: {
      CalendarConnectionStartedEvent,
      BookingAvailabilityCheckRequestedEvent,
      RescheduleAvailabilityCheckRequestedEvent,
      CalendarEventRequestedEvent,
      CalendarEventUpdateRequestedEvent,
      CalendarEventDeletionRequestedEvent,
      MeetingCanceledEvent,
      MeetingCompletedEvent,
      MeetingBookingFailedEvent,
    },
    handle: handle,
  );

  List<ScheduledJob> get jobs => [
    ScheduledJob(name: 'calendar:free-busy', interval: const Duration(minutes: 1), run: reportFreeBusy),
    ScheduledJob(name: 'calendar:direct-changes', interval: const Duration(seconds: 30), run: reportDirectChanges),
  ];

  Future<void> handle(StoredEvent stored) async {
    switch (stored.event) {
      case CalendarConnectionStartedEvent(:final hostId):
        await _connect(hostId.value);
      case BookingAvailabilityCheckRequestedEvent(:final meetingId, :final hostId, :final slotStart, :final slotEnd):
        await _checkAvailability(meetingId.value, hostId.value, slotStart.value, slotEnd.value);
      case RescheduleAvailabilityCheckRequestedEvent(
        :final meetingId,
        :final hostId,
        :final newSlotStart,
        :final newSlotEnd,
      ):
        await _checkAvailability(meetingId.value, hostId.value, newSlotStart.value, newSlotEnd.value);
      case CalendarEventRequestedEvent(:final meetingId):
        await _createEvent(meetingId.value);
      case CalendarEventUpdateRequestedEvent(:final meetingId):
        await _moveEvent(meetingId.value);
      case CalendarEventDeletionRequestedEvent(:final meetingId):
        await _deleteEvent(meetingId.value);
      case MeetingCanceledEvent(:final meetingId) ||
          MeetingCompletedEvent(:final meetingId) ||
          MeetingBookingFailedEvent(:final meetingId):
        await _views.delete(_eventsView, meetingId.value);
      default:
        break;
    }
  }

  Future<CalendarUser?> _employee(String employeeId) async {
    final read = await _store.read([
      (tag: 'employeeId', value: employeeId, eventTypes: [EmployeeRegisteredEvent]),
    ]);
    if (read.events.isEmpty) return null;
    final registered = read.events.last.event as EmployeeRegisteredEvent;
    return (employeeId: employeeId, email: registered.employeeEmail.value);
  }

  Future<void> _connect(String hostId) async {
    final ref = SchedulerUserRef(hostId);
    final user = await _employee(hostId);
    if (user == null) {
      await _store.append([
        CalendarAccessFailedEvent(failureCode: FailureCode('employee_unknown'), schedulerUserRef: ref),
      ]);
      return;
    }
    try {
      final account = await _calendar.connect(user);
      await _views.put(_hostsView, hostId, {'employeeId': hostId, 'email': user.email, 'reported': null});
      await _store.append([CalendarAccessGrantedEvent(schedulerUserRef: ref, calendarAccount: account)]);
      await _reportFreeBusyOf(hostId, user, null);
    } on CalendarFailure catch (failure) {
      await _views.delete(_hostsView, hostId);
      await _store.append([CalendarAccessFailedEvent(failureCode: FailureCode(failure.code), schedulerUserRef: ref)]);
    }
  }

  Future<void> _checkAvailability(String meetingId, String hostId, DateTime start, DateTime end) async {
    final ref = SchedulerMeetingRef(meetingId);
    final user = await _employee(hostId);
    try {
      if (user == null) throw const CalendarFailure('employee_unknown');
      final free = await _calendar.isFree(user, start, end, ignoringMeetingRef: meetingId);
      await _store.append([
        free ? HostSlotFoundFreeEvent(schedulerMeetingRef: ref) : HostSlotFoundBusyEvent(schedulerMeetingRef: ref),
      ]);
    } on CalendarFailure catch (failure) {
      await _store.append([
        AvailabilityCheckFailedEvent(failureCode: FailureCode(failure.code), schedulerMeetingRef: ref),
      ]);
    }
  }

  Future<T?> _last<T extends DomainEvent>(String meetingId) async {
    final read = await _store.read([
      (tag: 'meetingId', value: meetingId, eventTypes: [T]),
    ]);
    return read.events.isEmpty ? null : read.events.last.event as T;
  }

  Future<void> _createEvent(String meetingId) async {
    final ref = SchedulerMeetingRef(meetingId);
    if (await _views.get(_eventsView, meetingId) != null) return; // Delivered again after the event was created.
    final reserved = await _last<MeetingSlotReservedEvent>(meetingId);
    try {
      if (reserved == null) throw const CalendarFailure('meeting_unknown');
      final host = await _employee(reserved.hostId.value) ?? (throw const CalendarFailure('employee_unknown'));
      final providerRef = await _calendar.createEvent(
        host,
        CalendarEventDetails(
          schedulerMeetingRef: meetingId,
          title: reserved.meetingTitle.value,
          location: reserved.meetingLocation.value,
          start: reserved.slotStart.value,
          end: reserved.slotEnd.value,
          attendeeEmails: [for (final p in reserved.participants.items) p.email.value],
        ),
      );
      await _track(meetingId, host, providerRef, reserved.slotStart.value, reserved.slotEnd.value);
      await _store.append([CalendarEventCreatedEvent(schedulerMeetingRef: ref, providerEventRef: providerRef)]);
    } on CalendarFailure catch (failure) {
      await _store.append([
        CalendarEventCreationFailedEvent(failureCode: FailureCode(failure.code), schedulerMeetingRef: ref),
      ]);
    }
  }

  Future<void> _track(String meetingId, CalendarUser host, String providerRef, DateTime start, DateTime end) =>
      _views.put(_eventsView, meetingId, {
        'meetingId': meetingId,
        'hostId': host.employeeId,
        'hostEmail': host.email,
        'providerEventRef': providerRef,
        'start': start.toUtc().toIso8601String(),
        'end': end.toUtc().toIso8601String(),
      });

  Future<void> _moveEvent(String meetingId) async {
    final ref = SchedulerMeetingRef(meetingId);
    final tracked = await _views.get(_eventsView, meetingId);
    final request = await _last<MeetingRescheduleRequestedEvent>(meetingId);
    try {
      if (tracked == null || request == null) throw const CalendarFailure('event_not_found');
      final host = (employeeId: tracked['hostId'] as String, email: tracked['hostEmail'] as String);
      final start = request.newSlotStart.value, end = request.newSlotEnd.value;
      await _calendar.moveEvent(host, tracked['providerEventRef'] as String, start, end);
      await _track(meetingId, host, tracked['providerEventRef'] as String, start, end);
      await _store.append([CalendarEventUpdatedEvent(schedulerMeetingRef: ref)]);
    } on CalendarFailure catch (failure) {
      await _store.append([
        CalendarEventUpdateFailedEvent(failureCode: FailureCode(failure.code), schedulerMeetingRef: ref),
      ]);
    }
  }

  Future<void> _deleteEvent(String meetingId) async {
    final ref = SchedulerMeetingRef(meetingId);
    final tracked = await _views.get(_eventsView, meetingId);
    try {
      if (tracked == null) throw const CalendarFailure('event_not_found');
      final host = (employeeId: tracked['hostId'] as String, email: tracked['hostEmail'] as String);
      await _calendar.deleteEvent(host, tracked['providerEventRef'] as String);
      await _views.delete(_eventsView, meetingId);
      await _store.append([CalendarEventDeletedEvent(schedulerMeetingRef: ref)]);
    } on CalendarFailure catch (failure) {
      await _store.append([
        CalendarEventDeletionFailedEvent(failureCode: FailureCode(failure.code), schedulerMeetingRef: ref),
      ]);
    }
  }

  /// Reports the free/busy data of each connected host whose data changed since the last report.
  Future<void> reportFreeBusy() async {
    for (final host in await _views.find(_hostsView)) {
      final hostId = host['employeeId'] as String;
      await _reportFreeBusyOf(hostId, (employeeId: hostId, email: host['email'] as String), host['reported']);
    }
  }

  Future<void> _reportFreeBusyOf(String hostId, CalendarUser user, Object? lastReported) async {
    final now = _clock.now();
    final ref = SchedulerUserRef(hostId);
    try {
      final blocks = await _calendar.freeBusy(user, now, now.add(freeBusyHorizon));
      final encoded = [for (final b in blocks) '${b.from.toIso8601String()}/${b.until.toIso8601String()}'];
      if (lastReported is List && lastReported.join(',') == encoded.join(',')) return;
      await _store.append([
        FreeBusyReportedEvent(
          freeBusyBlocks: FreeBusyBlocks([for (final b in blocks) FreeBusyBlock(busyFrom: b.from, busyUntil: b.until)]),
          schedulerUserRef: ref,
        ),
      ]);
      await _views.put(_hostsView, hostId, {'employeeId': hostId, 'email': user.email, 'reported': encoded});
    } on CalendarFailure catch (failure) {
      _log.warning('Free/busy of $hostId failed: $failure');
      // The host must connect again; until then the scheduler offers no unverified availability.
      await _views.delete(_hostsView, hostId);
      await _store.append([CalendarAccessFailedEvent(failureCode: FailureCode(failure.code), schedulerUserRef: ref)]);
    }
  }

  /// Reports the meeting events that someone moved or deleted directly in the calendar.
  Future<void> reportDirectChanges() async {
    final tracked = await _views.find(_eventsView);
    final byHost = <String, List<Map<String, Object?>>>{};
    for (final t in tracked) {
      (byHost[t['hostEmail'] as String] ??= []).add(t);
    }
    for (final MapEntry(key: email, value: docs) in byHost.entries) {
      final host = (employeeId: docs.first['hostId'] as String, email: email);
      final byProviderRef = {for (final d in docs) d['providerEventRef'] as String: d};
      try {
        final changes = await _calendar.directChanges(host, [
          for (final d in docs)
            (
              providerEventRef: d['providerEventRef'] as String,
              start: DateTime.parse(d['start'] as String),
              end: DateTime.parse(d['end'] as String),
            ),
        ]);
        for (final change in changes) {
          final meetingId = byProviderRef[change.providerEventRef]!['meetingId'] as String;
          final ref = SchedulerMeetingRef(meetingId);
          switch (change) {
            case CalendarEventMoved(:final start, :final end):
              await _track(meetingId, host, change.providerEventRef, start, end);
              await _store.append([
                CalendarEventMovedDirectlyEvent(schedulerMeetingRef: ref, movedStart: start, movedEnd: end),
              ]);
            case CalendarEventRemoved():
              await _views.delete(_eventsView, meetingId);
              await _store.append([CalendarEventDeletedDirectlyEvent(schedulerMeetingRef: ref)]);
          }
        }
      } on CalendarFailure catch (failure) {
        _log.warning('Direct changes of $email failed: $failure');
      }
    }
  }
}
