import '../event_store/in_memory_event_store.dart';
import 'event_subscription.dart';

/// Delivers the events of an [InMemoryEventStore] to subscriptions when [drain] runs. For tests.
///
/// Every subscription sees every event of its types once, in append order. A handler error propagates.
final class InMemoryEventStreamer implements EventStreamer {
  InMemoryEventStreamer(this._store);

  final InMemoryEventStore _store;
  final List<EventSubscription> _subscriptions = [];
  final Map<String, int> _cursors = {};

  @override
  Future<void> start(List<EventSubscription> subscriptions) async {
    for (final s in subscriptions) {
      if (_cursors.containsKey(s.name)) throw ArgumentError('Duplicate subscription name: ${s.name}');
      _cursors[s.name] = 0;
      _subscriptions.add(s);
    }
  }

  @override
  Future<void> stop() async {}

  /// Delivers events until no subscription has an undelivered event, also the events that handlers append.
  Future<void> drain() async {
    var progressed = true;
    while (progressed) {
      progressed = false;
      for (final subscription in _subscriptions) {
        final events = _store.all;
        final cursor = _cursors[subscription.name]!;
        for (final event in events.skip(cursor)) {
          _cursors[subscription.name] = event.position;
          progressed = true;
          if (subscription.eventTypes.contains(event.event.runtimeType)) await subscription.handle(event);
        }
      }
    }
  }
}
