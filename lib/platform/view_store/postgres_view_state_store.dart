import 'package:postgres/postgres.dart';

import '../../bounded_contexts/event_contract.dart';
import '../postgres/database.dart';
import 'view_state_store.dart';

/// The [ViewStateStore] on the `fstore.view_states` table.
final class PostgresViewStateStore implements ViewStateStore {
  PostgresViewStateStore(this._db);

  final Session _db;

  @override
  Future<JsonMap?> get(String view, String key) async {
    final rows = await _db.execute(
      sql('SELECT data FROM fstore.view_states WHERE view = \$1 AND key = \$2'),
      parameters: [view, key],
    );
    return rows.isEmpty ? null : (rows.first[0] as Map).cast<String, Object?>();
  }

  @override
  Future<void> put(String view, String key, JsonMap data) async {
    await _db.execute(
      sql(
        'INSERT INTO fstore.view_states (view, key, data) VALUES (\$1, \$2, \$3) '
        'ON CONFLICT (view, key) DO UPDATE SET data = EXCLUDED.data, updated_at = NOW()',
      ),
      parameters: [view, key, TypedValue(Type.jsonb, data)],
    );
  }

  @override
  Future<void> delete(String view, String key) async {
    await _db.execute(
      sql('DELETE FROM fstore.view_states WHERE view = \$1 AND key = \$2'),
      parameters: [view, key],
    );
  }

  @override
  Future<List<JsonMap>> find(String view, {JsonMap where = const {}}) async {
    final rows = await _db.execute(
      sql('SELECT data FROM fstore.view_states WHERE view = \$1 AND data @> \$2 ORDER BY key'),
      parameters: [view, TypedValue(Type.jsonb, where)],
    );
    return [for (final row in rows) (row[0] as Map).cast<String, Object?>()];
  }
}
