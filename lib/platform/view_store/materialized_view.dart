import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/event_contract.dart';
import '../event_store/event_store.dart';
import '../event_streaming/event_subscription.dart';
import 'view_state_store.dart';

/// The fmodel [ViewStateRepository] of one materialized view: one JSON document per key in a [ViewStateStore].
///
/// The view state type is `S?`: `null` means "no document". When `evolve` returns `null`, [save] deletes the
/// document that the preceding [fetchState] loaded. The subscription that [materializedViewSubscription] makes
/// handles one event at a time, so the pair stays consistent.
abstract base class DocumentViewStateRepository<S extends Object>
    with ViewStateRepositoryDefaults<StoredEvent, S?>
    implements ViewStateRepository<StoredEvent, S?, NoMetadata> {
  DocumentViewStateRepository(this.store);

  final ViewStateStore store;
  String? _lastKey;

  /// The stable name of the view. It is the document namespace and the subscription name.
  String get viewName;

  /// The key of the document that [event] changes, or null when the event changes no document.
  ///
  /// Use the event fields, or `event.tagValue(...)` for a stream tag such as `hostId` on a meeting event.
  String? keyOf(StoredEvent event);

  /// The key of [state]. It must equal [keyOf] of every event that built the state.
  String keyOfState(S state);

  JsonMap encodeState(S state);

  S decodeState(JsonMap json);

  /// The document with [key], or null.
  Future<S?> load(String key) async {
    final json = await store.get(viewName, key);
    return json == null ? null : decodeState(json);
  }

  /// The documents whose JSON contains [where], ordered by key.
  Future<List<S>> findWhere([JsonMap where = const {}]) async => [
    for (final json in await store.find(viewName, where: where)) decodeState(json),
  ];

  @override
  Future<S?> fetchState(StoredEvent event) async {
    final key = _lastKey = keyOf(event);
    return key == null ? null : load(key);
  }

  @override
  Future<S?> save(S? state) async {
    if (state == null) {
      final key = _lastKey;
      if (key != null) await store.delete(viewName, key);
      return null;
    }
    await store.put(viewName, keyOfState(state), encodeState(state));
    return state;
  }
}

/// The subscription that keeps the documents of [repository] up to date with [view].
///
/// [view] is the pure fmodel `View` of the slice, over domain events. [eventTypes] are the events in the
/// `readmodel.from` list of the model. An event whose [DocumentViewStateRepository.keyOf] is null is skipped.
EventSubscription materializedViewSubscription<S extends Object, E extends DomainEvent>({
  required View<S?, E> view,
  required DocumentViewStateRepository<S> repository,
  required Set<Type> eventTypes,
}) {
  final materialized = createMaterializedView<S?, StoredEvent, NoMetadata>(
    view: view.mapLeftOnEvent<StoredEvent>((stored) => stored.event as E),
    viewStateRepository: repository,
  );
  return EventSubscription(
    name: 'view:${repository.viewName}',
    eventTypes: eventTypes,
    handle: (stored) async {
      if (repository.keyOf(stored) == null) return;
      await materialized.handle(stored);
    },
  );
}
