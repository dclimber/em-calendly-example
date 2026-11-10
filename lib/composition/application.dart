import 'dart:async';
import 'dart:io' show Cookie, HttpHeaders, SameSite;

import 'package:jaspr/dom.dart' show link;
import 'package:jaspr/server.dart';
import 'package:logging/logging.dart';
import 'package:shelf_router/shelf_router.dart';

import '../bounded_contexts/corporate_sso/api.dart';
import '../landing/landing_page.dart';
import '../platform/auth/authenticator.dart';
import '../platform/corporate_calendar/calendar_bridge.dart';
import '../platform/corporate_calendar/mock_corporate_calendar.dart';
import '../platform/event_streaming/event_subscription.dart';
import '../platform/jobs/job_scheduler.dart';
import '../platform/web/http.dart';
import '../ui/dev_calendar_console.dart';
import '../ui/layout.dart';
import '../ui/paths.dart';
import '../ui/platform_pages.dart';
import 'app_services.dart';
import 'vertical_slice.dart';

/// Renders a component as a full HTML document (jaspr's `serveApp` render function).
typedef RenderDocument = FutureOr<Response> Function(Component document);

/// The running application: the slices, the HTTP routes, the event subscriptions, and the jobs.
final class Application {
  Application({
    required this.services,
    required List<VerticalSlice> slices,
    required Authenticator authenticator,
    required EventStreamer streamer,
    required CalendarBridge calendarBridge,
    MockCorporateCalendar? mockCalendar,
  }) : _authenticator = authenticator,
       _streamer = streamer,
       _bridge = calendarBridge {
    for (final slice in slices) {
      slice.register(registrar, services);
    }
    if (mockCalendar != null) registerDevCalendarConsole(registrar, mockCalendar, calendarBridge);
    registrar.navigation.sort((a, b) => a.order.compareTo(b.order));
    _router = _buildRouter();
  }

  final AppServices services;
  final SliceRegistrar registrar = SliceRegistrar();
  final Authenticator _authenticator;
  final EventStreamer _streamer;
  final CalendarBridge _bridge;
  final JobScheduler _scheduler = JobScheduler();
  final Map<String, (AuthUser, DateTime)> _tokenCache = {};
  final _log = Logger('app');
  late final Router _router;

  static const accessCookie = 'sb-access';
  static const refreshCookie = 'sb-refresh';
  static const _viewerKey = 'app.viewer';
  static const _renderKey = 'app.render';

  /// Every subscription: the slices' and the calendar bridge's.
  List<EventSubscription> get subscriptions => [...registrar.subscriptions, _bridge.subscription];

  /// Every scheduled job: the slices' and the calendar bridge's.
  List<ScheduledJob> get jobs => [...registrar.jobs, ..._bridge.jobs];

  /// Starts the event subscriptions and the jobs.
  Future<void> start() async {
    await _streamer.start(subscriptions);
    _scheduler.start(jobs);
  }

  Future<void> stop() async {
    _scheduler.stop();
    await _streamer.stop();
  }

  Router _buildRouter() {
    final router = Router(notFoundHandler: (request) => _render(request, 'Not found', const NotFoundPage()));
    for (final route in registrar.pages) {
      router.get(route.path, (Request request) {
        final pageRequest = PageRequest(
          viewer: request.context[_viewerKey] as Viewer,
          pathParameters: request.params,
          query: request.url.queryParameters,
          path: request.requestedUri.path,
        );
        return _render(request, route.title, route.builder(pageRequest));
      });
    }
    for (final route in registrar.forms) {
      router.post(route.path, (Request request) async {
        final formRequest = FormRequest(
          viewer: request.context[_viewerKey] as Viewer,
          pathParameters: request.params,
          fields: parseFormBody(await request.readAsString()),
          request: request,
        );
        try {
          return await route.handler(formRequest);
        } on FormInputError catch (e) {
          return errorRedirect(_back(request), e.message);
        }
      });
    }
    for (final (path, handler) in registrar.rawRoutes) {
      router.get(path, handler);
    }
    router.get(homeRoute, (Request request) {
      return _render(request, 'Welcome', HomePage(navigation: registrar.navigation));
    });
    return router;
  }

  /// The page that sent a form: its `Referer`, or the form path itself.
  static String _back(Request request) {
    final referer = request.headers['referer'];
    if (referer == null) return request.requestedUri.path;
    final uri = Uri.parse(referer);
    final query = Map.of(uri.queryParameters)
      ..remove('notice')
      ..remove('error');
    return Uri(path: uri.path, queryParameters: query.isEmpty ? null : query).toString();
  }

  FutureOr<Response> _render(Request request, String title, Component page) {
    final render = request.context[_renderKey] as RenderDocument;
    final query = request.url.queryParameters;
    return render(
      Document(
        title: '$title · Meeting Scheduler',
        // The client script path is relative; nested pages such as /meetings/<id> need the root as base.
        base: '/',
        head: [link(rel: 'stylesheet', href: '/styles.css')],
        body: AppLayout(
          title: title,
          viewer: request.context[_viewerKey] as Viewer?,
          navigation: registrar.navigation,
          currentPath: request.requestedUri.path,
          notice: query['notice'],
          error: query['error'],
          child: page,
        ),
      ),
    );
  }

  /// Handles one request. [render] turns a component into an HTML response.
  Future<Response> handle(Request request, RenderDocument render) async {
    request = request.change(context: {_renderKey: render});
    try {
      final path = request.requestedUri.path;
      if (path != appRoot && !path.startsWith('$appRoot/')) return await _handlePublic(request, path);
      if (path == signInRoute || path == signUpRoute) return await _handleAuthPage(request, path);
      if (path == signOutRoute && request.method == 'POST') return await _signOut(request);

      final session = await _resolveSession(request);
      if (session == null) {
        final next = request.method == 'GET' ? request.requestedUri.toString() : homeRoute;
        return seeOther(Uri(path: signInRoute, queryParameters: {'next': Uri.parse(next).path}).toString());
      }
      final (viewer, cookies) = session;
      final response = await _router.call(request.change(context: {_viewerKey: viewer}));
      return cookies.isEmpty ? response : response.change(headers: {HttpHeaders.setCookieHeader: cookies});
    } catch (error, stackTrace) {
      _log.severe('${request.method} ${request.requestedUri} failed', error, stackTrace);
      return Response.internalServerError(body: 'Something went wrong. The error is logged.');
    }
  }

  /// The requests outside [appRoot]: the landing page, which needs no session, and a not-found page otherwise.
  FutureOr<Response> _handlePublic(Request request, String path) {
    if (path != landingRoute || request.method != 'GET') return _render(request, 'Not found', const NotFoundPage());
    final render = request.context[_renderKey] as RenderDocument;
    return render(
      Document(
        title: 'Meeting Scheduler · an app built from an event model',
        base: '/',
        meta: {
          'description':
              'A meeting booking tool for employees, written from an Event Modeling HCL model with fmodel-dart, '
              'fstore-sql, Supabase, and Jaspr.',
        },
        head: [link(rel: 'stylesheet', href: '/styles.css')],
        body: const LandingPage(),
      ),
    );
  }

  Future<Response> _handleAuthPage(Request request, String path) async {
    final next = request.url.queryParameters['next'] ?? homeRoute;
    if (request.method == 'GET') {
      return await _render(
        request,
        path == signInRoute ? 'Sign in' : 'Create account',
        path == signInRoute ? SignInPage(next: next) : const SignUpPage(),
      );
    }
    final fields = parseFormBody(await request.readAsString());
    String field(String name) => fields[name]?.firstOrNull?.trim() ?? '';
    try {
      final session = path == signInRoute
          ? await _authenticator.signIn(email: field('email'), password: field('password'))
          : await _authenticator.signUp(
              email: field('email'),
              password: field('password'),
              displayName: field('display_name'),
            );
      // The corporate SSO reports a successful sign-in; register_employee_on_first_sign_in translates it.
      await services.eventStore.append([
        CorporateSignInSucceededEvent(
          ssoSubject: session.user.id,
          displayName: session.user.displayName,
          workEmail: session.user.email,
        ),
      ]);
      return seeOther(next.startsWith('/') ? next : homeRoute).change(
        headers: {
          HttpHeaders.setCookieHeader: _sessionCookies(session),
        },
      );
    } on AuthFailure catch (failure) {
      return errorRedirect(request.requestedUri.toString(), failure.message);
    }
  }

  Future<Response> _signOut(Request request) async {
    final cookies = _cookies(request);
    final token = cookies[accessCookie];
    if (token != null) {
      _tokenCache.remove(token);
      await _authenticator.signOut(token);
    }
    return seeOther(signInRoute).change(
      headers: {
        HttpHeaders.setCookieHeader: [
          for (final name in [accessCookie, refreshCookie]) _cookie(name, '', maxAge: 0),
        ],
      },
    );
  }

  /// The viewer of the session cookies, and the cookies to set when the session was refreshed.
  Future<(Viewer, List<String>)?> _resolveSession(Request request) async {
    final cookies = _cookies(request);
    final access = cookies[accessCookie];
    if (access != null) {
      final cached = _tokenCache[access];
      if (cached != null && cached.$2.isAfter(DateTime.now())) return (_viewerOf(cached.$1), const <String>[]);
      final user = await _authenticator.userFor(access);
      if (user != null) {
        _tokenCache[access] = (user, DateTime.now().add(const Duration(minutes: 1)));
        return (_viewerOf(user), const <String>[]);
      }
    }
    final refresh = cookies[refreshCookie];
    if (refresh == null) return null;
    final session = await _authenticator.refresh(refresh);
    if (session == null) return null;
    return (_viewerOf(session.user), _sessionCookies(session));
  }

  static Viewer _viewerOf(AuthUser user) => Viewer(employeeId: user.id, name: user.displayName, email: user.email);

  static Map<String, String> _cookies(Request request) {
    final header = request.headers[HttpHeaders.cookieHeader];
    if (header == null) return const {};
    return {
      for (final part in header.split(';'))
        if (part.contains('='))
          part.substring(0, part.indexOf('=')).trim(): part.substring(part.indexOf('=') + 1).trim(),
    };
  }

  static List<String> _sessionCookies(AuthSession session) => [
    _cookie(accessCookie, session.accessToken, maxAge: 3600),
    _cookie(refreshCookie, session.refreshToken, maxAge: 60 * 60 * 24 * 30),
  ];

  static String _cookie(String name, String value, {required int maxAge}) =>
      (Cookie(name, value)
            ..path = '/'
            ..httpOnly = true
            ..sameSite = SameSite.lax
            ..maxAge = maxAge)
          .toString();
}
