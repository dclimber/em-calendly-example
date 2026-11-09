import 'corporate_calendar.dart';

/// The operations of [MockCorporateCalendar] that can be made to fail.
enum MockCalendarOperation { connect, freeBusy, availability, create, move, delete }

/// One event on the mock calendar.
final class MockCalendarEvent {
  MockCalendarEvent({
    required this.id,
    required this.organizerEmail,
    required this.details,
    required this.start,
    required this.end,
  });

  final String id;
  final String organizerEmail;
  final CalendarEventDetails details;
  DateTime start;
  DateTime end;
  bool removed = false;
}

/// A corporate calendar in memory, for local runs without Google credentials.
///
/// The `/dev/calendar` page drives it: it adds busy blocks, makes the next calls of an operation fail, and moves or
/// deletes events directly, as a person would in their calendar. Its state lives in the server process.
final class MockCorporateCalendar implements CorporateCalendar {
  final Map<String, List<BusyBlock>> _busy = {};
  final Map<String, MockCalendarEvent> _events = {};
  final Map<MockCalendarOperation, String> _failures = {};
  int _nextId = 1;

  // ---- Controls of the /dev/calendar page ----

  /// The busy blocks that the person entered in their calendar, by email.
  Map<String, List<BusyBlock>> get busyBlocks => {for (final e in _busy.entries) e.key: List.unmodifiable(e.value)};

  /// Every event that the scheduler created, also the removed ones.
  List<MockCalendarEvent> get events => List.unmodifiable(_events.values);

  /// The failure code of each operation that fails, until [clearFailure].
  Map<MockCalendarOperation, String> get failures => Map.unmodifiable(_failures);

  void addBusyBlock(String email, BusyBlock block) => (_busy[email.toLowerCase()] ??= []).add(block);

  void clearBusyBlocks(String email) => _busy.remove(email.toLowerCase());

  void failOperation(MockCalendarOperation operation, String code) => _failures[operation] = code;

  void clearFailure(MockCalendarOperation operation) => _failures.remove(operation);

  /// Moves an event as if someone dragged it in their calendar.
  void moveDirectly(String id, DateTime start, DateTime end) {
    final event = _events[id] ?? (throw ArgumentError('Unknown mock event $id'));
    event
      ..start = start.toUtc()
      ..end = end.toUtc();
  }

  /// Deletes an event as if someone removed it in their calendar.
  void deleteDirectly(String id) => (_events[id] ?? (throw ArgumentError('Unknown mock event $id'))).removed = true;

  // ---- CorporateCalendar ----

  void _check(MockCalendarOperation operation) {
    final code = _failures[operation];
    if (code != null) throw CalendarFailure(code, 'Mock failure of ${operation.name}');
  }

  Iterable<BusyBlock> _busyOf(String email, {String? ignoringMeetingRef}) sync* {
    yield* _busy[email.toLowerCase()] ?? const <BusyBlock>[];
    for (final event in _events.values) {
      if (event.removed || event.details.schedulerMeetingRef == ignoringMeetingRef) continue;
      final involved =
          event.organizerEmail == email.toLowerCase() ||
          event.details.attendeeEmails.any((a) => a.toLowerCase() == email.toLowerCase());
      if (involved) yield (from: event.start, until: event.end);
    }
  }

  @override
  Future<String> connect(CalendarUser user) async {
    _check(MockCalendarOperation.connect);
    return user.email;
  }

  @override
  Future<List<BusyBlock>> freeBusy(CalendarUser user, DateTime from, DateTime until) async {
    _check(MockCalendarOperation.freeBusy);
    final blocks = _busyOf(user.email).where((b) => b.until.isAfter(from) && b.from.isBefore(until)).toList()
      ..sort((a, b) => a.from.compareTo(b.from));
    return blocks;
  }

  @override
  Future<bool> isFree(CalendarUser user, DateTime start, DateTime end, {String? ignoringMeetingRef}) async {
    _check(MockCalendarOperation.availability);
    return !_busyOf(
      user.email,
      ignoringMeetingRef: ignoringMeetingRef,
    ).any((b) => b.from.isBefore(end) && b.until.isAfter(start));
  }

  @override
  Future<String> createEvent(CalendarUser organizer, CalendarEventDetails details) async {
    _check(MockCalendarOperation.create);
    final id = 'mock-event-${_nextId++}';
    _events[id] = MockCalendarEvent(
      id: id,
      organizerEmail: organizer.email.toLowerCase(),
      details: details,
      start: details.start.toUtc(),
      end: details.end.toUtc(),
    );
    return id;
  }

  @override
  Future<void> moveEvent(CalendarUser organizer, String providerEventRef, DateTime start, DateTime end) async {
    _check(MockCalendarOperation.move);
    final event = _events[providerEventRef];
    if (event == null || event.removed) throw CalendarFailure('event_not_found', providerEventRef);
    event
      ..start = start.toUtc()
      ..end = end.toUtc();
  }

  @override
  Future<void> deleteEvent(CalendarUser organizer, String providerEventRef) async {
    _check(MockCalendarOperation.delete);
    final event = _events[providerEventRef];
    if (event == null) throw CalendarFailure('event_not_found', providerEventRef);
    event.removed = true;
  }

  @override
  Future<List<DirectCalendarChange>> directChanges(CalendarUser organizer, List<TrackedCalendarEvent> events) async {
    return [
      for (final tracked in events)
        if (_events[tracked.providerEventRef] case final event?)
          if (event.removed)
            CalendarEventRemoved(event.id)
          else if (event.start != tracked.start.toUtc() || event.end != tracked.end.toUtc())
            CalendarEventMoved(event.id, start: event.start, end: event.end),
    ];
  }
}
