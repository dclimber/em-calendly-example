// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/client.dart';

import 'package:em_calendly_example/ui/local_time.dart' deferred as _local_time;

/// Default [ClientOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.client.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultClientOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ClientOptions get defaultClientOptions => ClientOptions(
  clients: {
    'local_time': ClientLoader(
      (p) => _local_time.LocalTime(
        iso: p['iso'] as String,
        timeOnly: p['timeOnly'] as bool,
      ),
      loader: _local_time.loadLibrary,
    ),
  },
);
