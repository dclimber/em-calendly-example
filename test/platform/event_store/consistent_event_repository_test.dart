import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/composition/event_catalog.dart';
import 'package:em_calendly_example/platform/event_store/consistent_event_repository.dart';
import 'package:em_calendly_example/platform/event_store/event_store.dart';
import 'package:em_calendly_example/platform/event_store/in_memory_event_store.dart';
import 'package:fmodel/fmodel.dart';
import 'package:test/test.dart';

/// "A host has at most three schedules": the decision reads every schedule of the host.
typedef _Create = ({String hostId, String scheduleId});

final _decider = Decider<_Create, int, HostSetupEvent>(
  initialState: 0,
  decide: (command, count) async* {
    if (count >= 3) throw StateError('limit');
    yield AvailabilityScheduleCreatedEvent(
      scheduleId: ScheduleId(command.scheduleId),
      hostId: HostId(command.hostId),
      scheduleName: ScheduleName('S'),
      timeZone: TimeZone('UTC'),
    );
  },
  evolve: (count, event) => event is AvailabilityScheduleCreatedEvent ? count + 1 : count,
);

final class _Repository extends ConsistentEventRepository<_Create, HostSetupEvent> {
  _Repository(super.store);

  @override
  List<EventQuery> queriesFor(_Create command) => [
    (tag: 'hostId', value: command.hostId, eventTypes: [AvailabilityScheduleCreatedEvent]),
  ];
}

/// Appends a rival schedule between the read and the append of the first [races] decisions.
final class _RacingStore implements EventStore {
  _RacingStore(this._inner, this.races);

  final EventStore _inner;
  int races;

  @override
  Future<EventStoreRead> read(List<EventQuery> queries) async {
    final read = await _inner.read(queries);
    if (races > 0) {
      races--;
      await _inner.append([
        AvailabilityScheduleCreatedEvent(
          scheduleId: ScheduleId('rival-$races'),
          hostId: HostId('alice'),
          scheduleName: ScheduleName('Rival'),
          timeZone: TimeZone('UTC'),
        ),
      ]);
    }
    return read;
  }

  @override
  Future<List<StoredEvent>> append(List<DomainEvent> events, {AppendCondition? condition}) =>
      _inner.append(events, condition: condition);
}

void main() {
  late InMemoryEventStore inner;
  setUp(() => inner = InMemoryEventStore(buildEventCatalog()));

  Future<List<HostSetupEvent>> create(EventStore store, String scheduleId) => handleCommand(
    () => createEventSourcingAggregate(decider: _decider, eventRepository: _Repository(store)),
    (hostId: 'alice', scheduleId: scheduleId),
  );

  // @requires a rival writer appends a matching event while the decision runs
  // @ensures the command runs again on the new history, and the rule holds
  test('retries a decision that lost a race, on the new history', () async {
    final events = await create(_RacingStore(inner, 1), 'mine');
    expect(events.single, isA<AvailabilityScheduleCreatedEvent>());
    expect((await inner.read(_Repository(inner).queriesFor((hostId: 'alice', scheduleId: '')))).events, hasLength(2));

    // The rival now fills the limit before the retry, so the retried decision rejects.
    await expectLater(create(_RacingStore(inner, 1), 'late'), throwsA(isA<StateError>()));
  });

  // @ensures after the last attempt the conflict reaches the caller
  test('gives up after the attempts are used', () async {
    await expectLater(create(_RacingStore(inner, 5), 'mine'), throwsA(isA<AppendConditionFailed>()));
  });
}
