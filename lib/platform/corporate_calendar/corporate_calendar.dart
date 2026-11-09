/// The corporate calendar system, as the scheduler sees it: free/busy data and the events of booked meetings.
///
/// Adapters: [GoogleCorporateCalendar] (Google Workspace, with a service account and domain-wide delegation) and
/// [MockCorporateCalendar] (in memory, driven from `/dev/calendar`).
library;

/// The calendar of one employee.
typedef CalendarUser = ({String employeeId, String email});

/// One busy interval. Holds no title, attendee, or content.
typedef BusyBlock = ({DateTime from, DateTime until});

/// The event of a booked meeting.
final class CalendarEventDetails {
  const CalendarEventDetails({
    required this.schedulerMeetingRef,
    required this.title,
    required this.location,
    required this.start,
    required this.end,
    required this.attendeeEmails,
  });

  /// The meeting id. The adapter stores it on the event, so the scheduler can find its events again.
  final String schedulerMeetingRef;
  final String title;
  final String location;
  final DateTime start;
  final DateTime end;
  final List<String> attendeeEmails;
}

/// The last known state of an event that the scheduler created.
typedef TrackedCalendarEvent = ({String providerEventRef, DateTime start, DateTime end});

/// A change that someone made directly in the calendar, outside the scheduler.
sealed class DirectCalendarChange {
  const DirectCalendarChange(this.providerEventRef);

  final String providerEventRef;
}

final class CalendarEventMoved extends DirectCalendarChange {
  const CalendarEventMoved(super.providerEventRef, {required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}

final class CalendarEventRemoved extends DirectCalendarChange {
  const CalendarEventRemoved(super.providerEventRef);
}

/// The calendar system refused or could not answer. [code] becomes the `failure_code` of the model.
final class CalendarFailure implements Exception {
  const CalendarFailure(this.code, [this.detail = '']);

  final String code;
  final String detail;

  @override
  String toString() => 'CalendarFailure($code${detail.isEmpty ? '' : ': $detail'})';
}

/// The corporate calendar port. Every method throws [CalendarFailure] when the calendar fails.
abstract interface class CorporateCalendar {
  /// Checks that the scheduler may read free/busy data and write events for [user], and returns the account name.
  Future<String> connect(CalendarUser user);

  /// The busy blocks of [user] between [from] and [until].
  Future<List<BusyBlock>> freeBusy(CalendarUser user, DateTime from, DateTime until);

  /// Whether [user] is free from [start] to [end]. The event of [ignoringMeetingRef], if any, does not count.
  Future<bool> isFree(CalendarUser user, DateTime start, DateTime end, {String? ignoringMeetingRef});

  /// Creates the event on the calendar of [organizer], invites the attendees, and returns the provider event id.
  Future<String> createEvent(CalendarUser organizer, CalendarEventDetails details);

  Future<void> moveEvent(CalendarUser organizer, String providerEventRef, DateTime start, DateTime end);

  Future<void> deleteEvent(CalendarUser organizer, String providerEventRef);

  /// The direct changes to [events] on the calendar of [organizer].
  Future<List<DirectCalendarChange>> directChanges(CalendarUser organizer, List<TrackedCalendarEvent> events);
}
