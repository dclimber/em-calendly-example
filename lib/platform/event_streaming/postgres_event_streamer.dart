import 'dart:async';
import 'dart:math';

import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart';

import '../event_store/event_catalog.dart';
import '../event_store/postgres_event_store.dart';
import '../postgres/database.dart';
import 'event_subscription.dart';

/// Delivers events to subscriptions with fstore-sql event streaming: `register_view`, `stream_events`, `ack_event`,
/// and `schedule_nack_event`.
///
/// Each subscription runs its own polling loop. `stream_events` locks one partition (`decider_id`) at a time, so
/// events of one partition arrive in order, and partitions can be handled by several server instances at once.
final class PostgresEventStreamer implements EventStreamer {
  PostgresEventStreamer(
    this._db,
    this._store,
    this._catalog, {
    this.batchSize = 50,
    this.lockTimeout = const Duration(seconds: 60),
    this.idleDelay = const Duration(milliseconds: 300),
  });

  final Session _db;
  final PostgresEventStore _store;
  final EventCatalog _catalog;
  final int batchSize;
  final Duration lockTimeout;
  final Duration idleDelay;
  final _log = Logger('event_streaming');
  final Map<String, int> _attempts = {};
  final List<Future<void>> _loops = [];
  bool _running = false;

  @override
  Future<void> start(List<EventSubscription> subscriptions) async {
    final names = <String>{};
    for (final s in subscriptions) {
      if (!names.add(s.name)) throw ArgumentError('Duplicate subscription name: ${s.name}');
    }
    _running = true;
    for (final subscription in subscriptions) {
      await _registerView(subscription.name);
      _loops.add(_run(subscription));
    }
  }

  @override
  Future<void> stop() async {
    _running = false;
    await Future.wait(_loops);
    _loops.clear();
  }

  /// Registers the fstore-sql view once. Registering again would reset its offsets and replay every event.
  Future<void> _registerView(String name) async {
    final exists = await _db.execute(sql('SELECT 1 FROM fstore.views WHERE view = \$1'), parameters: [name]);
    if (exists.isNotEmpty) return;
    await _db.execute(
      sql("SELECT * FROM fstore.register_view(\$1, '1970-01-01'::timestamp, \$2, NULL, NULL)"),
      parameters: [name, lockTimeout.inSeconds],
    );
    _log.info('Registered fstore-sql view $name');
  }

  Future<void> _run(EventSubscription subscription) async {
    final wanted = {for (final type in subscription.eventTypes) _catalog.typeNameFor(type)};
    while (_running) {
      try {
        final delivered = await pollOnce(subscription, wanted);
        if (delivered == 0) await Future<void>.delayed(idleDelay);
      } catch (error, stackTrace) {
        _log.severe('Subscription ${subscription.name} failed to poll', error, stackTrace);
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    }
  }

  /// Streams one batch to [subscription] and returns the number of events in it.
  Future<int> pollOnce(EventSubscription subscription, Set<String> wantedTypeNames) async {
    final name = subscription.name;
    final rows = await _db.execute(
      sql('SELECT "offset", decider_id, event FROM fstore.stream_events(\$1, \$2, \$3)'),
      parameters: [name, batchSize, lockTimeout.inSeconds],
    );
    if (rows.isEmpty) return 0;
    final batch = [for (final r in rows) (offset: r[0] as int, partition: r[1] as String, type: r[2] as String)];
    final stored = {
      for (final e in await _store.readPositions([
        for (final row in batch)
          if (wantedTypeNames.contains(row.type)) row.offset,
      ]))
        e.position: e,
    };
    for (final row in batch) {
      final event = stored[row.offset];
      final key = '$name/${row.offset}';
      try {
        if (event != null) await subscription.handle(event);
        _attempts.remove(key);
        await _db.execute(
          sql('SELECT * FROM fstore.ack_event(\$1, \$2, \$3)'),
          parameters: [name, row.partition, row.offset],
        );
      } catch (error, stackTrace) {
        final attempt = _attempts[key] = (_attempts[key] ?? 0) + 1;
        final delay = Duration(milliseconds: min(60000, 500 * pow(2, attempt - 1).toInt()));
        _log.warning(
          '$name failed on ${row.type}@${row.offset} (attempt $attempt), retry in $delay',
          error,
          stackTrace,
        );
        await _db.execute(
          sql('SELECT * FROM fstore.schedule_nack_event(\$1, \$2, \$3)'),
          parameters: [name, row.partition, delay.inMilliseconds],
        );
      }
    }
    return batch.length;
  }
}
