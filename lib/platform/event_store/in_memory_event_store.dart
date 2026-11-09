import '../../bounded_contexts/event_contract.dart';
import 'event_catalog.dart';
import 'event_store.dart';
import 'stream_tags.dart';

/// An [EventStore] in memory, with the same semantics as the fstore-sql adapter. For tests.
final class InMemoryEventStore implements EventStore {
  InMemoryEventStore(this._catalog, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  final EventCatalog _catalog;
  final DateTime Function() _now;
  final List<StoredEvent> _events = [];

  /// Every stored event, in append order.
  List<StoredEvent> get all => List.unmodifiable(_events);

  @override
  Future<EventStoreRead> read(List<EventQuery> queries) async {
    final events = _events.where((e) => queries.any(e.matches)).toList();
    return EventStoreRead(events: events, position: events.isEmpty ? 0 : events.last.position);
  }

  @override
  Future<List<StoredEvent>> append(List<DomainEvent> events, {AppendCondition? condition}) async {
    if (condition != null && _events.any((e) => e.position > condition.after && condition.queries.any(e.matches))) {
      throw AppendConditionFailed(condition);
    }
    final appended = <StoredEvent>[];
    for (final event in events) {
      final stream = _catalog.streamOf(event);
      final first = _events.where((e) => e.stream == stream).firstOrNull;
      final stored = StoredEvent(
        event: event,
        typeName: _catalog.typeNameOf(event),
        position: _events.length + 1,
        stream: stream,
        tags: withStreamTags(_catalog.tagsOf(event), first?.tags ?? const <EventTag>[]),
        recordedAt: _now().toUtc(),
      );
      _events.add(stored);
      appended.add(stored);
    }
    return appended;
  }
}
