import 'dart:io' show HttpHeaders;

import 'package:em_calendly_example/bounded_contexts/event_contract.dart';
import 'package:em_calendly_example/composition/app_services.dart';
import 'package:em_calendly_example/composition/application.dart';
import 'package:em_calendly_example/composition/event_catalog.dart';
import 'package:em_calendly_example/composition/slice_registry.dart';
import 'package:em_calendly_example/composition/vertical_slice.dart';
import 'package:em_calendly_example/platform/auth/authenticator.dart';
import 'package:em_calendly_example/platform/corporate_calendar/calendar_bridge.dart';
import 'package:em_calendly_example/platform/corporate_calendar/mock_corporate_calendar.dart';
import 'package:em_calendly_example/platform/event_store/event_store.dart';
import 'package:em_calendly_example/platform/event_store/in_memory_event_store.dart';
import 'package:em_calendly_example/platform/event_streaming/in_memory_event_streamer.dart';
import 'package:em_calendly_example/platform/mail/mailer.dart';
import 'package:em_calendly_example/platform/time/clock.dart';
import 'package:em_calendly_example/platform/view_store/in_memory_view_state_store.dart';
import 'package:em_calendly_example/platform/web/http.dart';
import 'package:jaspr/server.dart';

/// Alice, the host in the examples of the model.
const alice = Viewer(employeeId: 'alice-employee-id', name: 'Alice Host', email: 'alice@example.com');

/// Bob, the booker in the examples of the model.
const bob = Viewer(employeeId: 'bob-employee-id', name: 'Bob Booker', email: 'bob@example.com');

/// The whole application in memory: real slices, routes, pages, subscriptions, and the mock calendar, with a fixed
/// clock and in-memory adapters. Events reach subscriptions only when [drain] runs, so a test controls each step.
final class TestApp {
  TestApp({DateTime? now, List<VerticalSlice> slices = verticalSlices, IdGenerator ids = const UuidGenerator()})
    : clock = FixedClock(now ?? DateTime.utc(2027, 3, 15, 8)) {
    final catalog = buildEventCatalog();
    events = InMemoryEventStore(catalog, now: clock.now);
    streamer = InMemoryEventStreamer(events);
    services = AppServices(
      eventStore: events,
      viewStore: views,
      clock: clock,
      ids: ids,
      mailer: mailer,
      publicBaseUrl: Uri.parse('http://scheduler.test'),
    );
    bridge = CalendarBridge(eventStore: events, viewStore: views, calendar: calendar, clock: clock);
    app = Application(
      services: services,
      slices: slices,
      authenticator: auth,
      streamer: streamer,
      calendarBridge: bridge,
      mockCalendar: calendar,
    );
  }

  final FixedClock clock;
  late final InMemoryEventStore events;
  final InMemoryViewStateStore views = InMemoryViewStateStore();
  final RecordingMailer mailer = RecordingMailer();
  final MockCorporateCalendar calendar = MockCorporateCalendar();
  final FakeAuthenticator auth = FakeAuthenticator();
  late final InMemoryEventStreamer streamer;
  late final AppServices services;
  late final CalendarBridge bridge;
  late final Application app;

  /// Starts the subscriptions (not the job timers; call [runJobs]).
  Future<void> start() async {
    if (!Jaspr.isInitialized) Jaspr.initializeApp();
    await streamer.start(app.subscriptions);
  }

  /// Delivers every pending event to every subscription, until nothing changes.
  Future<void> drain() => streamer.drain();

  /// Runs every scheduled job once, then [drain]s.
  Future<void> runJobs() async {
    for (final job in app.jobs) {
      await job.run();
    }
    await drain();
  }

  /// Appends [events] as if another part of the system recorded them.
  Future<List<StoredEvent>> given(List<DomainEvent> events) => this.events.append(events);

  Future<TestResponse> get(String path, {Viewer? as}) => _send('GET', path, as: as);

  /// Posts a form. A list value sends a repeated field.
  Future<TestResponse> post(String path, Map<String, Object> fields, {Viewer? as}) {
    final body = [
      for (final MapEntry(:key, :value) in fields.entries)
        for (final v in value is List ? value : [value])
          '${Uri.encodeQueryComponent(key)}=${Uri.encodeQueryComponent('$v')}',
    ].join('&');
    return _send('POST', path, as: as, body: body);
  }

  Future<TestResponse> _send(String method, String path, {Viewer? as, String? body}) async {
    final headers = <String, String>{
      if (body != null) HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
      if (as != null) HttpHeaders.cookieHeader: '${Application.accessCookie}=${auth.tokenFor(as)}',
    };
    final request = Request(method, Uri.parse('http://scheduler.test$path'), headers: headers, body: body);
    final response = await app.handle(request, (component) async {
      final rendered = await renderComponent(component, request: request);
      return Response(rendered.statusCode, body: rendered.body, headers: rendered.headers);
    });
    return TestResponse(response.statusCode, response.headers, await response.readAsString());
  }
}

final class TestResponse {
  const TestResponse(this.statusCode, this.headers, this.body);

  final int statusCode;
  final Map<String, String> headers;
  final String body;

  /// The redirect target of a 303 response.
  String? get location => headers['location'];

  /// The path of [location], without the query.
  String? get redirectPath => location == null ? null : Uri.parse(location!).path;

  /// The `notice` flash message of a redirect.
  String? get notice => location == null ? null : Uri.parse(location!).queryParameters['notice'];

  /// The `error` flash message of a redirect.
  String? get error => location == null ? null : Uri.parse(location!).queryParameters['error'];

  @override
  String toString() => 'TestResponse($statusCode, location: $location)';
}

/// Signs in any [Viewer] with a token `token-<employeeId>`.
final class FakeAuthenticator implements Authenticator {
  final Map<String, AuthUser> _users = {};

  String tokenFor(Viewer viewer) {
    final token = 'token-${viewer.employeeId}';
    _users[token] = AuthUser(id: viewer.employeeId, email: viewer.email, displayName: viewer.name);
    return token;
  }

  @override
  Future<AuthSession> signIn({required String email, required String password}) async {
    final user = _users.values.where((u) => u.email == email).firstOrNull;
    if (user == null || password.isEmpty) throw const AuthFailure('Invalid login credentials');
    return AuthSession(accessToken: 'token-${user.id}', refreshToken: 'refresh-${user.id}', user: user);
  }

  @override
  Future<AuthSession> signUp({required String email, required String password, required String displayName}) async {
    final user = AuthUser(id: 'user-${_users.length + 1}', email: email, displayName: displayName);
    _users['token-${user.id}'] = user;
    return AuthSession(accessToken: 'token-${user.id}', refreshToken: 'refresh-${user.id}', user: user);
  }

  @override
  Future<AuthUser?> userFor(String accessToken) async => _users[accessToken];

  @override
  Future<AuthSession?> refresh(String refreshToken) async => null;

  @override
  Future<void> signOut(String accessToken) async {}
}
