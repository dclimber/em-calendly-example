import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/event_contract.dart';
import 'event_store.dart';

/// The fmodel [EventRepository] of a decider, on the [EventStore] port.
///
/// [fetchEvents] reads the events of [queriesFor], and [save] appends the new events only if no other writer has
/// appended an event that matches the same queries in the meantime (a Dynamic Consistency Boundary). The store
/// serializes appends per tag, so the decision and its append are atomic for every tag in the queries.
///
/// Create one instance for each command: [fetchEvents] keeps the condition that the following [save] uses.
/// [handleCommand] does this, and retries when the condition fails.
abstract base class ConsistentEventRepository<C, E extends DomainEvent>
    with EventRepositoryDefaults<C, E>
    implements EventRepository<C, E, NoMetadata, NoMetadata> {
  ConsistentEventRepository(this.store);

  final EventStore store;
  AppendCondition? _condition;

  /// The event store queries for every event that the decision of [command] reads.
  List<EventQuery> queriesFor(C command);

  @override
  Stream<E> fetchEvents(C command) async* {
    final queries = queriesFor(command);
    final read = await store.read(queries);
    _condition = read.conditionFor(queries);
    for (final stored in read.events) {
      yield stored.event as E;
    }
  }

  @override
  Stream<E> save(Stream<E> events) async* {
    final decided = await events.toList();
    final stored = await store.append(decided, condition: _condition);
    for (final s in stored) {
      yield s.event as E;
    }
  }
}

/// Handles [command] with a fresh aggregate from [aggregate], and returns the new events.
///
/// When another writer appended a conflicting event first ([AppendConditionFailed]), the command runs again on the
/// new history, up to [attempts] times. A decider error passes through unchanged.
Future<List<E>> handleCommand<C, S, E>(
  EventSourcingAggregate<C, S, E, NoMetadata, NoMetadata> Function() aggregate,
  C command, {
  int attempts = 3,
}) async {
  for (var attempt = 1; ; attempt++) {
    try {
      return await aggregate().handle(command).toList();
    } on AppendConditionFailed {
      if (attempt >= attempts) rethrow;
    }
  }
}
