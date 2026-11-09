@Tags(['db'])
library;

import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/composition/event_catalog.dart';
import 'package:em_calendly_example/platform/event_store/event_store.dart';
import 'package:em_calendly_example/platform/event_store/postgres_event_store.dart';
import 'package:em_calendly_example/platform/postgres/database.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../../support/database.dart';
import 'event_store_contract.dart';

void main() {
  group('PostgresEventStore', () {
    final catalog = buildEventCatalog();
    late Pool<void> db;
    setUpAll(() => db = testDatabase());

    eventStoreContract(() => PostgresEventStore(db, catalog));

    // @ensures each appended event extends its fstore-sql decider stream: previous_id points to the stream's last event
    test('keeps the fstore-sql stream chain', () async {
      final store = PostgresEventStore(db, catalog);
      final id = const Uuid().v4();
      await store.append([MeetingTypeDisabledEvent(meetingTypeId: MeetingTypeId(id))]);
      await store.append([MeetingTypeEnabledEvent(meetingTypeId: MeetingTypeId(id))]);
      final rows = await db.execute(
        sql(
          'SELECT e.event, p.event FROM fstore.events e LEFT JOIN fstore.events p ON p.event_id = e.previous_id '
          'WHERE e.decider = \$1 AND e.decider_id = \$2 ORDER BY e."offset"',
        ),
        parameters: ['meeting_type', id],
      );
      expect(rows.map((r) => [r[0], r[1]]), [
        ['MeetingTypeDisabledEvent', null],
        ['MeetingTypeEnabledEvent', 'MeetingTypeDisabledEvent'],
      ]);
    });

    // @requires two writers decide on the same read of one tag at the same time
    // @ensures exactly one of them appends; the other gets AppendConditionFailed
    test('serializes concurrent conditional appends per tag', () async {
      final hostId = const Uuid().v4();
      final queries = <EventQuery>[
        (tag: 'hostId', value: hostId, eventTypes: [AvailabilityScheduleCreatedEvent]),
      ];
      final stores = [PostgresEventStore(db, catalog), PostgresEventStore(db, catalog)];
      final reads = await Future.wait(stores.map((s) => s.read(queries)));
      final results = await Future.wait([
        for (var i = 0; i < 2; i++)
          stores[i]
              .append([
                AvailabilityScheduleCreatedEvent(
                  scheduleId: ScheduleId(const Uuid().v4()),
                  hostId: HostId(hostId),
                  scheduleName: ScheduleName('Schedule $i'),
                  timeZone: TimeZone('Europe/Berlin'),
                ),
              ], condition: reads[i].conditionFor(queries))
              .then<Object>((v) => v, onError: (Object e) => e),
      ]);
      expect(results.whereType<AppendConditionFailed>(), hasLength(1));
      expect((await stores.first.read(queries)).events, hasLength(1));
    });
  });
}
