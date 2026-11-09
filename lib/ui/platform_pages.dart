import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import '../composition/vertical_slice.dart';
import 'kit.dart';
import 'paths.dart';

/// The sign-in form of the corporate account (Supabase Auth).
class SignInPage extends StatelessComponent {
  const SignInPage({required this.next, super.key});

  /// Where to go after signing in.
  final String next;

  @override
  Component build(BuildContext context) {
    return Panel(
      children: [
        PostForm(
          action: Uri(path: signInRoute, queryParameters: {'next': next}).toString(),
          submitLabel: 'Sign in',
          children: [
            Field(
              label: 'Work email',
              input: textInput('email', type: 'email', required: true),
            ),
            Field(
              label: 'Password',
              input: textInput('password', type: 'password', required: true),
            ),
          ],
        ),
        p([
          .text('No account yet? '),
          a(href: signUpRoute, [.text('Create one')]),
        ]),
      ],
    );
  }
}

/// The account creation form. Local Supabase Auth stands in for the corporate identity provider.
class SignUpPage extends StatelessComponent {
  const SignUpPage({super.key});

  @override
  Component build(BuildContext context) {
    return Panel(
      children: [
        PostForm(
          action: signUpRoute,
          submitLabel: 'Create account',
          children: [
            Field(label: 'Display name', input: textInput('display_name', required: true)),
            Field(
              label: 'Work email',
              input: textInput('email', type: 'email', required: true),
            ),
            Field(
              label: 'Password',
              input: textInput('password', type: 'password', required: true),
              hint: 'At least 6 characters.',
            ),
          ],
        ),
        p([
          .text('Have an account? '),
          a(href: signInRoute, [.text('Sign in')]),
        ]),
      ],
    );
  }
}

/// The start page: one entry for each navigation link of the registered slices.
class HomePage extends StatelessComponent {
  const HomePage({required this.navigation, super.key});

  final List<NavItem> navigation;

  @override
  Component build(BuildContext context) {
    if (navigation.isEmpty) return const EmptyState('No screens are available yet.');
    return div(classes: 'tiles', [
      for (final item in navigation)
        a(href: item.path, classes: 'tile', [
          span([.text(item.label)]),
        ]),
    ]);
  }
}

/// The page for an unknown path.
class NotFoundPage extends StatelessComponent {
  const NotFoundPage({super.key});

  @override
  Component build(BuildContext context) {
    context.setStatusCode(404);
    return p([
      .text('This page does not exist. '),
      a(href: homeRoute, [.text('Go to the start page')]),
    ]);
  }
}
