import 'package:em_calendly_example/bounded_contexts/corporate_sso/api.dart';
import 'package:em_calendly_example/composition/app_services.dart';
import 'package:em_calendly_example/composition/vertical_slice.dart';
import 'package:em_calendly_example/platform/web/http.dart';
import 'package:jaspr/dom.dart';
import 'package:test/test.dart';

import '../support/test_app.dart';

/// A slice that exercises the registrar: a page with a path parameter, and a form that validates its input.
final class _ProbeSlice implements VerticalSlice {
  const _ProbeSlice();

  @override
  String get name => 'probe';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    registrar
      ..nav(const NavItem(label: 'Probe', path: '/app/probe/x', order: 1))
      ..page(
        '/app/probe/<id>',
        title: 'Probe',
        builder: (r) => p([.text('id=${r.param('id')} viewer=${r.viewer.name}')]),
      )
      ..form('/app/probe/<id>', (r) async {
        final count = int.tryParse(r.requiredField('count', label: 'Count')) ?? (throw const FormInputError('Bad.'));
        return noticeRedirect('/app/probe/${r.param('id')}', 'Got $count and ${r.all('tag').join('+')}');
      });
  }
}

void main() {
  late TestApp t;
  setUp(() async {
    t = TestApp(slices: const [_ProbeSlice()]);
    await t.start();
  });

  // @ensures every screen requires a signed-in employee
  test('redirects an anonymous request to the sign-in page, keeping the path', () async {
    final response = await t.get('/app/probe/1');
    expect(response.statusCode, 303);
    expect(response.location, '/app/sign-in?next=%2Fapp%2Fprobe%2F1');
  });

  // @ensures a sign-up starts a session and reports the corporate sign-in to the event store
  test('signing up sets the session cookies and records corporate_sign_in_succeeded', () async {
    final response = await t.post('/app/sign-up', {
      'display_name': 'Carol',
      'email': 'carol@example.com',
      'password': 'secret-1',
    });
    expect(response.statusCode, 303);
    expect(response.headers['set-cookie'], contains('sb-access='));
    expect(t.events.all.single.event, isA<CorporateSignInSucceededEvent>());
    final event = t.events.all.single.event as CorporateSignInSucceededEvent;
    expect((event.displayName, event.workEmail), ('Carol', 'carol@example.com'));
  });

  // @ensures a registered page renders inside the layout with its path parameters and the viewer
  test('renders a registered page for a signed-in viewer', () async {
    final response = await t.get('/app/probe/42', as: alice);
    expect(response.statusCode, 200);
    expect(response.body, contains('id=42 viewer=Alice Host'));
    expect(response.body, contains('href="/app/probe/x"'));
    expect(response.body, contains('Dev calendar'));
  });

  // @ensures a form handler receives repeated fields and its redirect carries the notice
  test('posts a form with repeated fields to its handler', () async {
    final response = await t.post('/app/probe/7', {
      'count': '3',
      'tag': ['a', 'b'],
    }, as: alice);
    expect(response.redirectPath, '/app/probe/7');
    expect(response.notice, 'Got 3 and a+b');
  });

  // @ensures a FormInputError becomes an error redirect, not a server error
  test('turns invalid form input into an error message', () async {
    final response = await t.post('/app/probe/7', {}, as: alice);
    expect(response.statusCode, 303);
    expect(response.error, 'Count is required.');
  });

  // @ensures an unknown path renders the not-found page with status 404
  test('renders 404 for an unknown path', () async {
    final response = await t.get('/app/nope', as: alice);
    expect(response.statusCode, 404);
    expect(response.body, contains('This page does not exist'));
  });

  // @ensures the landing page at / is public and leads into the app at /app
  test('serves the landing page without a session', () async {
    final response = await t.get('/');
    expect(response.statusCode, 200);
    expect(response.body, contains('Book time with a colleague in one step.'));
    expect(response.body, contains('href="/app"'));
    expect(response.body, contains('Meeting slot reserved'));
  });

  // @ensures only the landing page is outside /app; other paths there need no session and do not exist
  test('answers 404 outside /app without asking for a sign-in', () async {
    final response = await t.get('/probe/1');
    expect(response.statusCode, 404);
  });

  // @ensures a slice cannot register a route outside /app, where it would bypass the sign-in
  test('refuses a slice route outside /app', () {
    expect(() => SliceRegistrar().page('/probe', title: 'Probe', builder: (_) => p([])), throwsArgumentError);
  });
}
