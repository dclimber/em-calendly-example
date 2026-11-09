import '../../bounded_contexts/event_contract.dart';

/// The events of [eventTypes] that carry the tag [tag] with the value [value].
typedef EventQuery = ({String tag, String value, List<Type> eventTypes});

/// An event as the store holds it.
final class StoredEvent {
  const StoredEvent({
    required this.event,
    required this.typeName,
    required this.position,
    required this.stream,
    required this.tags,
    required this.recordedAt,
  });

  final DomainEvent event;

  /// The stable type name, for example `MeetingSlotReservedEvent`.
  final String typeName;

  /// The global append order (fstore-sql `offset`). It starts at 1.
  final int position;

  /// The fstore-sql stream: `decider` and `decider_id`.
  final EventStream stream;

  /// The tags of the event's own fields, plus the tags of the first event of its stream.
  final List<EventTag> tags;

  final DateTime recordedAt;

  /// The value of [tag], or null when the event does not carry it.
  String? tagValue(String tag) {
    for (final t in tags) {
      if (t.tag == tag) return t.value;
    }
    return null;
  }

  bool matches(EventQuery query) =>
      query.eventTypes.contains(event.runtimeType) && tags.any((t) => t.tag == query.tag && t.value == query.value);
}

/// The result of [EventStore.read].
final class EventStoreRead {
  const EventStoreRead({required this.events, required this.position});

  /// The matching events, in append order.
  final List<StoredEvent> events;

  /// The position of the last matching event, or 0 when no event matches.
  final int position;

  AppendCondition conditionFor(List<EventQuery> queries) => AppendCondition(queries: queries, after: position);
}

/// Append only when no event that matches [queries] was appended after position [after].
///
/// The store serializes appends per tag, so the check and the append are atomic.
final class AppendCondition {
  const AppendCondition({required this.queries, required this.after});

  final List<EventQuery> queries;
  final int after;
}

/// Another writer appended an event that the decision did not see.
final class AppendConditionFailed implements Exception {
  const AppendConditionFailed(this.condition);

  final AppendCondition condition;

  @override
  String toString() =>
      'AppendConditionFailed: an event that matches the decision queries was appended after '
      'position ${condition.after}.';
}

/// The event store port. Adapters: in memory (tests) and fstore-sql on Postgres.
abstract interface class EventStore {
  /// The events that match at least one of [queries], in append order.
  Future<EventStoreRead> read(List<EventQuery> queries);

  /// Appends [events] atomically, in order.
  ///
  /// Throws [AppendConditionFailed] when [condition] does not hold.
  Future<List<StoredEvent>> append(List<DomainEvent> events, {AppendCondition? condition});
}
