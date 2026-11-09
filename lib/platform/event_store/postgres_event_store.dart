import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

import '../../bounded_contexts/event_contract.dart';
import '../postgres/database.dart';
import 'event_catalog.dart';
import 'event_store.dart';
import 'stream_tags.dart';

/// The [EventStore] on fstore-sql (`supabase/migrations`), in the `fstore` schema.
///
/// - Each event is appended with `fstore.append_event` to its decider stream, with `previous_id` set to the last
///   event of that stream, so fstore-sql's stream constraints hold.
/// - `fstore.event_tags` holds the tags of each event, for queries across streams.
/// - An append takes a transaction-level advisory lock for each stream and each tag that it writes or that its
///   [AppendCondition] reads. Thus, the condition check and the insert are atomic per tag.
final class PostgresEventStore implements EventStore {
  PostgresEventStore(this._db, this._catalog);

  final Session _db;
  final EventCatalog _catalog;
  final Set<String> _registeredDeciders = {};
  static const _uuid = Uuid();

  static const _eventColumns = '''
    e."offset", e.event, e.decider, e.decider_id, e.data, e.created_at,
    COALESCE((SELECT jsonb_agg(jsonb_build_array(t.tag, t.value) ORDER BY t.tag, t.value)
              FROM fstore.event_tags t WHERE t."offset" = e."offset"), '[]'::jsonb) AS tags''';

  static const _matching = '''
    WITH q(tag, value, event) AS (SELECT * FROM unnest(\$1::text[], \$2::text[], \$3::text[])),
    hits AS (SELECT DISTINCT t."offset"
             FROM fstore.event_tags t
             JOIN q ON q.tag = t.tag AND q.value = t.value
             JOIN fstore.events m ON m."offset" = t."offset" AND m.event = q.event)''';

  List<Object> _queryParameters(List<EventQuery> queries) {
    final tags = <String>[], values = <String>[], events = <String>[];
    for (final query in queries) {
      for (final type in query.eventTypes) {
        tags.add(query.tag);
        values.add(query.value);
        events.add(_catalog.typeNameFor(type));
      }
    }
    return [TypedValue(Type.textArray, tags), TypedValue(Type.textArray, values), TypedValue(Type.textArray, events)];
  }

  @override
  Future<EventStoreRead> read(List<EventQuery> queries) async {
    if (queries.isEmpty) return const EventStoreRead(events: [], position: 0);
    final result = await _db.execute(
      sql(
        '$_matching SELECT $_eventColumns FROM fstore.events e JOIN hits h ON h."offset" = e."offset" '
        'ORDER BY e."offset"',
      ),
      parameters: _queryParameters(queries),
    );
    final events = result.map((row) => decodeRow(row.toColumnMap())).toList();
    return EventStoreRead(events: events, position: events.isEmpty ? 0 : events.last.position);
  }

  /// Decodes a row with the columns of `_eventColumns`.
  StoredEvent decodeRow(Map<String, dynamic> row) {
    final typeName = row['event'] as String;
    return StoredEvent(
      event: _catalog.decode(typeName, (row['data'] as Map).cast<String, Object?>()),
      typeName: typeName,
      position: row['offset'] as int,
      stream: (type: row['decider'] as String, id: row['decider_id'] as String),
      tags: [
        for (final pair in row['tags'] as List) (tag: (pair as List)[0] as String, value: pair[1] as String),
      ],
      recordedAt: (row['created_at'] as DateTime).toUtc(),
    );
  }

  /// The SQL that selects the stored events at [positions], for adapters that read `fstore.events` rows.
  Future<List<StoredEvent>> readPositions(List<int> positions) async {
    if (positions.isEmpty) return const [];
    final result = await _db.execute(
      sql(
        'SELECT $_eventColumns FROM fstore.events e WHERE e."offset" = ANY(\$1::bigint[]) '
        'ORDER BY e."offset"',
      ),
      parameters: [TypedValue(Type.bigIntegerArray, positions)],
    );
    return result.map((row) => decodeRow(row.toColumnMap())).toList();
  }

  @override
  Future<List<StoredEvent>> append(List<DomainEvent> events, {AppendCondition? condition}) async {
    if (events.isEmpty) return const [];
    return switch (_db) {
      final SessionExecutor executor => executor.runTx((tx) => _append(tx, events, condition)),
      final Session session => _append(session, events, condition),
    };
  }

  Future<List<StoredEvent>> _append(Session tx, List<DomainEvent> events, AppendCondition? condition) async {
    final pending = [
      for (final event in events)
        (
          event: event,
          typeName: _catalog.typeNameOf(event),
          stream: _catalog.streamOf(event),
          own: _catalog.tagsOf(event),
        ),
    ];

    // The tags of the first event of a stream never change, so they can be read before the locks.
    final streamTags = <EventStream, List<EventTag>>{};
    for (final p in pending) {
      if (streamTags.containsKey(p.stream)) continue;
      final rows = await tx.execute(
        sql(
          'SELECT t.tag, t.value FROM fstore.event_tags t WHERE t."offset" = '
          '(SELECT min("offset") FROM fstore.events WHERE decider = \$1 AND decider_id = \$2) ORDER BY t.tag, t.value',
        ),
        parameters: [p.stream.type, p.stream.id],
      );
      streamTags[p.stream] = [for (final r in rows) (tag: r[0] as String, value: r[1] as String)];
    }
    // The first event of a new stream gives the stream tags to the later events of the same batch.
    final tagged = [
      for (final p in pending)
        (
          p: p,
          tags: withStreamTags(
            p.own,
            streamTags[p.stream]!.isEmpty ? (streamTags[p.stream] = p.own) : streamTags[p.stream]!,
          ),
        ),
    ];

    final lockKeys = <String>{
      for (final t in tagged) 'stream:${t.p.stream.type}:${t.p.stream.id}',
      for (final t in tagged)
        for (final tag in t.tags) 'tag:${tag.tag}:${tag.value}',
      for (final q in condition?.queries ?? const <EventQuery>[]) 'tag:${q.tag}:${q.value}',
    }.toList()..sort();
    for (final key in lockKeys) {
      await tx.execute(sql('SELECT pg_advisory_xact_lock(hashtextextended(\$1, 0))'), parameters: [key]);
    }

    if (condition != null) {
      final conflict = await tx.execute(
        sql('$_matching SELECT EXISTS (SELECT 1 FROM hits WHERE hits."offset" > \$4)'),
        parameters: [..._queryParameters(condition.queries), condition.after],
      );
      if (conflict.first[0] == true) throw AppendConditionFailed(condition);
    }

    final commandId = _uuid.v4();
    final positions = <int>[];
    for (final t in tagged) {
      await _registerDecider(tx, t.p.stream.type, t.p.typeName);
      final previous = await tx.execute(
        sql(
          'SELECT event_id::text FROM fstore.events WHERE decider = \$1 AND decider_id = \$2 '
          'ORDER BY "offset" DESC LIMIT 1',
        ),
        parameters: [t.p.stream.type, t.p.stream.id],
      );
      final appended = await tx.execute(
        sql(
          'SELECT "offset" FROM fstore.append_event(\$1, \$2::uuid, \$3, \$4, \$5::jsonb, \$6::uuid, \$7::uuid)',
        ),
        parameters: [
          t.p.typeName,
          _uuid.v4(),
          t.p.stream.type,
          t.p.stream.id,
          TypedValue(Type.jsonb, _catalog.encode(t.p.event)),
          commandId,
          previous.isEmpty ? null : previous.first[0] as String,
        ],
      );
      final position = appended.first[0] as int;
      positions.add(position);
      await tx.execute(
        sql(
          'INSERT INTO fstore.event_tags ("offset", tag, value) '
          'SELECT \$1, tag, value FROM unnest(\$2::text[], \$3::text[]) AS x(tag, value)',
        ),
        parameters: [
          position,
          TypedValue(Type.textArray, [for (final tag in t.tags) tag.tag]),
          TypedValue(Type.textArray, [for (final tag in t.tags) tag.value]),
        ],
      );
    }

    final stored = await tx.execute(
      sql(
        'SELECT $_eventColumns FROM fstore.events e WHERE e."offset" = ANY(\$1::bigint[]) ORDER BY e."offset"',
      ),
      parameters: [TypedValue(Type.bigIntegerArray, positions)],
    );
    return stored.map((row) => decodeRow(row.toColumnMap())).toList();
  }

  /// fstore-sql accepts an event only after its (decider, event) pair is registered.
  Future<void> _registerDecider(Session tx, String decider, String event) async {
    final key = '$decider/$event';
    if (_registeredDeciders.contains(key)) return;
    // `deciders` has an UPDATE rule, so `ON CONFLICT` is not allowed; a lock serializes the check instead.
    await tx.execute(sql('SELECT pg_advisory_xact_lock(hashtextextended(\'fstore.deciders\', 0))'));
    await tx.execute(
      sql(
        'INSERT INTO fstore.deciders (decider, event, event_version, description) '
        'SELECT \$1, \$2, 1, \$2 WHERE NOT EXISTS '
        '(SELECT 1 FROM fstore.deciders WHERE decider = \$1 AND event = \$2 AND event_version = 1)',
      ),
      parameters: [decider, event],
    );
    _registeredDeciders.add(key);
  }
}
