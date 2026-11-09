import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../composition/vertical_slice.dart';
import '../platform/web/http.dart';
import 'paths.dart';

/// The frame of every page: the navigation, the title, the flash messages, and the page body.
class AppLayout extends StatelessComponent {
  const AppLayout({
    required this.title,
    required this.child,
    this.viewer,
    this.navigation = const [],
    this.currentPath = '/',
    this.notice,
    this.error,
    super.key,
  });

  final String title;
  final Component child;

  /// Null on the sign-in and sign-up pages.
  final Viewer? viewer;
  final List<NavItem> navigation;
  final String currentPath;
  final String? notice;
  final String? error;

  @override
  Component build(BuildContext context) {
    return div(classes: 'app', [
      header(classes: 'topbar', [
        a(href: homeRoute, classes: 'brand', [.text('Meeting Scheduler')]),
        if (viewer != null)
          nav([
            for (final item in navigation)
              a(
                href: item.path,
                classes: currentPath == item.path || currentPath.startsWith('${item.path}/') ? 'active' : null,
                [.text(item.label)],
              ),
          ]),
        if (viewer case final v?)
          div(classes: 'who', [
            span([.text(v.name)]),
            form(action: signOutRoute, method: .post, classes: 'inline', [
              button(type: .submit, classes: 'button small', [.text('Sign out')]),
            ]),
          ]),
      ]),
      main_(classes: 'page', [
        h1([.text(title)]),
        if (notice case final n?) div(classes: 'flash notice', attributes: {'role': 'status'}, [.text(n)]),
        if (error case final e?) div(classes: 'flash error', attributes: {'role': 'alert'}, [.text(e)]),
        child,
      ]),
    ]);
  }
}
