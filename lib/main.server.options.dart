// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:em_calendly_example/components/counter.dart' as _counter;
import 'package:em_calendly_example/components/header.dart' as _header;
import 'package:em_calendly_example/constants/theme.dart' as _theme;
import 'package:em_calendly_example/pages/about.dart' as _about;
import 'package:em_calendly_example/app.dart' as _app;

/// Default [ServerOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.server.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultServerOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ServerOptions get defaultServerOptions => ServerOptions(
  clientId: 'main.client.dart.js',
  clients: {_app.App: ClientTarget<_app.App>('app')},
  styles: () => [
    ..._theme.styles,
    ..._app.AppState.styles,
    ..._counter.CounterState.styles,
    ..._header.Header.styles,
    ..._about.About.styles,
  ],
);
