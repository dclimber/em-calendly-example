import '../platform/event_store/event_store.dart';
import '../platform/mail/mailer.dart';
import '../platform/time/clock.dart';
import '../platform/view_store/view_state_store.dart';

/// The ports that slices use. Composition builds it once, from the environment or for a test.
final class AppServices {
  const AppServices({
    required this.eventStore,
    required this.viewStore,
    required this.clock,
    required this.ids,
    required this.mailer,
    required this.publicBaseUrl,
  });

  final EventStore eventStore;

  /// The documents of materialized views.
  final ViewStateStore viewStore;
  final Clock clock;
  final IdGenerator ids;
  final Mailer mailer;

  /// The public address of the application, for links that people copy or receive by email.
  final Uri publicBaseUrl;

  /// The absolute URL of [path], for example a booking link.
  String absoluteUrl(String path) => publicBaseUrl.resolve(path).toString();
}
