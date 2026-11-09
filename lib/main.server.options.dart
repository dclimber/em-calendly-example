// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:em_calendly_example/ui/local_time.dart' as _local_time;

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
  clients: {
    _local_time.LocalTime: ClientTarget<_local_time.LocalTime>(
      'local_time',
      params: __local_timeLocalTime,
    ),
  },
);

Map<String, Object?> __local_timeLocalTime(_local_time.LocalTime c) => {
  'iso': c.iso,
  'timeOnly': c.timeOnly,
};
