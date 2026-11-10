@Tags(['db'])
library;

import 'dart:async';

import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/composition/event_catalog.dart';
import 'package:em_calendly_example/platform/event_store/event_store.dart';
import 'package:em_calendly_example/platform/event_store/postgres_event_store.dart';
import 'package:em_calendly_example/platform/event_streaming/event_subscription.dart';
import 'package:em_calendly_example/platform/event_streaming/postgres_event_streamer.dart';
import 'package:em_calendly_example/platform/postgres/database.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../../support/database.dart';

void main() {
  group('PostgresEventStreamer', () {
    final catalog = buildEventCatalog();
    late Pool<void> db;
    late PostgresEventStore store;
    late PostgresEventStreamer streamer;
    late String name;
    setUpAll(() async {
      db = await testDatabase();
      store = PostgresEventStore(db, catalog);
    });
    setUp(() {
      name = 'test-${const Uuid().v4()}';
      streamer = PostgresEventStreamer(db, store, catalog, idleDelay: const Duration(milliseconds: 20));
      // fstore-sql keeps a lock row per view and partition; a stale test view would slow every later append.
      addTearDown(() => db.execute(sql('DELETE FROM fstore.views WHERE view = \$1'), parameters: [name]));
      addTearDown(streamer.stop);
    });

    /// Waits until [received] holds [count] events of [meetingTypeId].
    Future<List<StoredEvent>> receivedFor(List<StoredEvent> received, String meetingTypeId, int count) async {
      final deadline = DateTime.now().add(const Duration(seconds: 20));
      while (DateTime.now().isBefore(deadline)) {
        final mine = received.where((e) => e.tagValue('meetingTypeId') == meetingTypeId).toList();
        if (mine.length >= count) return mine;
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      fail('Timed out waiting for $count events of $meetingTypeId');
    }

    // @ensures a new subscription receives the events of its types in stream order, each once, decoded with tags
    test('delivers the subscribed events of a stream in order', () async {
      final id = const Uuid().v4();
      await store.append([MeetingTypeDisabledEvent(meetingTypeId: MeetingTypeId(id))]);
      await store.append([MeetingTypeEnabledEvent(meetingTypeId: MeetingTypeId(id))]);
      await store.append([MeetingTypeDeletedEvent(meetingTypeId: MeetingTypeId(id))]);

      final received = <StoredEvent>[];
      await streamer.start([
        EventSubscription(
          name: name,
          eventTypes: {MeetingTypeDisabledEvent, MeetingTypeDeletedEvent},
          handle: (e) async => received.add(e),
        ),
      ]);

      final mine = await receivedFor(received, id, 2);
      expect(mine.map((e) => e.event), [
        MeetingTypeDisabledEvent(meetingTypeId: MeetingTypeId(id)),
        MeetingTypeDeletedEvent(meetingTypeId: MeetingTypeId(id)),
      ]);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(received.where((e) => e.tagValue('meetingTypeId') == id), hasLength(2));
    });

    // @requires the handler throws on the first delivery
    // @ensures the event is delivered again, and the next event of the partition waits for it
    test('redelivers an event whose handler failed', () async {
      final id = const Uuid().v4();
      await store.append([MeetingTypeDisabledEvent(meetingTypeId: MeetingTypeId(id))]);
      await store.append([MeetingTypeEnabledEvent(meetingTypeId: MeetingTypeId(id))]);

      final received = <StoredEvent>[];
      var failed = false;
      await streamer.start([
        EventSubscription(
          name: name,
          eventTypes: {MeetingTypeDisabledEvent, MeetingTypeEnabledEvent},
          handle: (e) async {
            if (e.tagValue('meetingTypeId') == id && e.event is MeetingTypeDisabledEvent && !failed) {
              failed = true;
              throw StateError('first delivery fails');
            }
            received.add(e);
          },
        ),
      ]);

      final mine = await receivedFor(received, id, 2);
      expect(failed, isTrue);
      expect(mine.map((e) => e.event.runtimeType), [MeetingTypeDisabledEvent, MeetingTypeEnabledEvent]);
    });
  });
}
