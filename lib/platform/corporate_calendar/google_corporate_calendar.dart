import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

import 'corporate_calendar.dart';

/// [CorporateCalendar] on Google Workspace Calendar.
///
/// It uses a service account with domain-wide delegation for the scope
/// `https://www.googleapis.com/auth/calendar`, and acts as each employee (impersonation by work email). A host
/// "connects" when the scheduler can read their free/busy data.
final class GoogleCorporateCalendar implements CorporateCalendar {
  GoogleCorporateCalendar(this._credentialsJson);

  /// The JSON key of the service account (the file that `GOOGLE_APPLICATION_CREDENTIALS` names).
  final Map<String, dynamic> _credentialsJson;
  final Map<String, Future<http.Client>> _clients = {};

  static const _calendarId = 'primary';
  static const _meetingRefKey = 'schedulerMeetingRef';

  Future<gcal.CalendarApi> _api(CalendarUser user) async {
    final client = _clients[user.email] ??= clientViaServiceAccount(
      ServiceAccountCredentials.fromJson(_credentialsJson, impersonatedUser: user.email),
      [gcal.CalendarApi.calendarScope],
    );
    return gcal.CalendarApi(await client);
  }

  Future<T> _call<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on gcal.DetailedApiRequestError catch (e) {
      throw CalendarFailure('google_${e.status ?? 'error'}', e.message ?? '');
    } on CalendarFailure {
      rethrow;
    } catch (e) {
      throw CalendarFailure('calendar_unreachable', '$e');
    }
  }

  @override
  Future<String> connect(CalendarUser user) async {
    final now = DateTime.now().toUtc();
    await freeBusy(user, now, now.add(const Duration(minutes: 1)));
    return user.email;
  }

  @override
  Future<List<BusyBlock>> freeBusy(CalendarUser user, DateTime from, DateTime until) => _call(() async {
    final api = await _api(user);
    final response = await api.freebusy.query(
      gcal.FreeBusyRequest(
        timeMin: from.toUtc(),
        timeMax: until.toUtc(),
        items: [gcal.FreeBusyRequestItem(id: user.email)],
      ),
    );
    final calendar = response.calendars?[user.email];
    final errors = calendar?.errors ?? const [];
    if (calendar == null || errors.isNotEmpty) {
      throw CalendarFailure('free_busy_unavailable', errors.map((e) => e.reason).join(', '));
    }
    return [
      for (final period in calendar.busy ?? const <gcal.TimePeriod>[])
        if (period.start != null && period.end != null) (from: period.start!.toUtc(), until: period.end!.toUtc()),
    ];
  });

  @override
  Future<bool> isFree(CalendarUser user, DateTime start, DateTime end, {String? ignoringMeetingRef}) => _call(() async {
    final api = await _api(user);
    final events = await api.events.list(
      _calendarId,
      timeMin: start.toUtc(),
      timeMax: end.toUtc(),
      singleEvents: true,
      maxResults: 250,
    );
    return !(events.items ?? const <gcal.Event>[]).any(
      (e) =>
          e.status != 'cancelled' &&
          e.transparency != 'transparent' &&
          (ignoringMeetingRef == null || e.extendedProperties?.private?[_meetingRefKey] != ignoringMeetingRef),
    );
  });

  @override
  Future<String> createEvent(CalendarUser organizer, CalendarEventDetails details) => _call(() async {
    final api = await _api(organizer);
    final created = await api.events.insert(
      gcal.Event(
        summary: details.title,
        location: details.location,
        start: gcal.EventDateTime(dateTime: details.start.toUtc()),
        end: gcal.EventDateTime(dateTime: details.end.toUtc()),
        attendees: [for (final email in details.attendeeEmails) gcal.EventAttendee(email: email)],
        extendedProperties: gcal.EventExtendedProperties(private: {_meetingRefKey: details.schedulerMeetingRef}),
      ),
      _calendarId,
      sendUpdates: 'all',
    );
    return created.id ?? (throw const CalendarFailure('event_without_id'));
  });

  @override
  Future<void> moveEvent(CalendarUser organizer, String providerEventRef, DateTime start, DateTime end) =>
      _call(() async {
        final api = await _api(organizer);
        await api.events.patch(
          gcal.Event(
            start: gcal.EventDateTime(dateTime: start.toUtc()),
            end: gcal.EventDateTime(dateTime: end.toUtc()),
          ),
          _calendarId,
          providerEventRef,
          sendUpdates: 'all',
        );
      });

  @override
  Future<void> deleteEvent(CalendarUser organizer, String providerEventRef) => _call(() async {
    final api = await _api(organizer);
    await api.events.delete(_calendarId, providerEventRef, sendUpdates: 'all');
  });

  @override
  Future<List<DirectCalendarChange>> directChanges(CalendarUser organizer, List<TrackedCalendarEvent> events) =>
      _call(() async {
        final api = await _api(organizer);
        final changes = <DirectCalendarChange>[];
        for (final tracked in events) {
          try {
            final event = await api.events.get(_calendarId, tracked.providerEventRef);
            final start = event.start?.dateTime?.toUtc();
            final end = event.end?.dateTime?.toUtc();
            if (event.status == 'cancelled') {
              changes.add(CalendarEventRemoved(tracked.providerEventRef));
            } else if (start != null && end != null && (start != tracked.start.toUtc() || end != tracked.end.toUtc())) {
              changes.add(CalendarEventMoved(tracked.providerEventRef, start: start, end: end));
            }
          } on gcal.DetailedApiRequestError catch (e) {
            if (e.status != 404 && e.status != 410) rethrow;
            changes.add(CalendarEventRemoved(tracked.providerEventRef));
          }
        }
        return changes;
      });
}
