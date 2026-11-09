import '../event_store/event_store.dart';

/// A consumer of the event stream: a materialized view, an automation, or an integration.
///
/// On Postgres, each subscription is one fstore-sql view: it receives every event of [eventTypes] once and in order
/// per stream partition (`decider_id`), at least once. A handler must therefore be idempotent. An exception makes
/// the event come back later with a growing delay; a business rejection that must not be retried must be caught by
/// the handler.
final class EventSubscription {
  const EventSubscription({required this.name, required this.eventTypes, required this.handle});

  /// The fstore-sql view name. It must be unique. A new name replays every stored event.
  final String name;

  /// The Dart event types that [handle] receives. Other events are acknowledged without a call.
  final Set<Type> eventTypes;

  final Future<void> Function(StoredEvent event) handle;
}

/// Runs subscriptions against an event store.
abstract interface class EventStreamer {
  /// Starts delivering events to [subscriptions] in the background.
  Future<void> start(List<EventSubscription> subscriptions);

  /// Stops the delivery loops.
  Future<void> stop();
}
