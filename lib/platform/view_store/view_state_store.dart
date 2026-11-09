import '../../bounded_contexts/event_contract.dart';

/// Stores the state of materialized views: one JSON document per view and key.
abstract interface class ViewStateStore {
  Future<JsonMap?> get(String view, String key);

  Future<void> put(String view, String key, JsonMap data);

  Future<void> delete(String view, String key);

  /// The documents of [view] whose data contains [where] (JSON containment, as Postgres `@>`), ordered by key.
  Future<List<JsonMap>> find(String view, {JsonMap where = const {}});
}
