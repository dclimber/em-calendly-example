import 'dart:convert';

import '../../bounded_contexts/event_contract.dart';
import 'view_state_store.dart';

/// A [ViewStateStore] in memory, with the same semantics as the Postgres adapter. For tests.
final class InMemoryViewStateStore implements ViewStateStore {
  final Map<String, Map<String, String>> _views = {};

  @override
  Future<JsonMap?> get(String view, String key) async {
    final json = _views[view]?[key];
    return json == null ? null : jsonDecode(json) as JsonMap;
  }

  @override
  Future<void> put(String view, String key, JsonMap data) async {
    // Stored as text, like JSONB: a state that does not survive a JSON round trip fails here too.
    (_views[view] ??= {})[key] = jsonEncode(data);
  }

  @override
  Future<void> delete(String view, String key) async {
    _views[view]?.remove(key);
  }

  @override
  Future<List<JsonMap>> find(String view, {JsonMap where = const {}}) async {
    final documents = _views[view] ?? const {};
    final keys = documents.keys.toList()..sort();
    return [
      for (final key in keys)
        if (_contains(jsonDecode(documents[key]!), where)) jsonDecode(documents[key]!) as JsonMap,
    ];
  }

  /// JSON containment with the rules of Postgres `jsonb @>`.
  static bool _contains(Object? data, Object? pattern) {
    if (pattern is Map) {
      return data is Map && pattern.entries.every((e) => data.containsKey(e.key) && _contains(data[e.key], e.value));
    }
    if (pattern is List) {
      return data is List && pattern.every((p) => data.any((d) => _contains(d, p)));
    }
    return data == pattern;
  }
}
