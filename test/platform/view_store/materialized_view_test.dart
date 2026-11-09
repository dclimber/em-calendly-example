import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/composition/event_catalog.dart';
import 'package:em_calendly_example/platform/event_store/event_store.dart';
import 'package:em_calendly_example/platform/event_store/in_memory_event_store.dart';
import 'package:em_calendly_example/platform/event_streaming/in_memory_event_streamer.dart';
import 'package:em_calendly_example/platform/view_store/in_memory_view_state_store.dart';
import 'package:em_calendly_example/platform/view_store/materialized_view.dart';
import 'package:em_calendly_example/platform/view_store/view_state_store.dart';
import 'package:fmodel/fmodel.dart';
import 'package:test/test.dart';

/// The ids of the active meeting types of one host.
typedef _ActiveTypes = ({String hostId, List<String> ids});

/// Keyed by the `hostId` stream tag, which the disabled and deleted events inherit from `meeting_type_created`.
final class _ActiveTypesRepository extends DocumentViewStateRepository<_ActiveTypes> {
  _ActiveTypesRepository(super.store);

  @override
  String get viewName => 'test_active_types';

  @override
  String? keyOf(StoredEvent event) => event.tagValue('hostId');

  @override
  String keyOfState(_ActiveTypes state) => state.hostId;

  @override
  JsonMap encodeState(_ActiveTypes state) => {'hostId': state.hostId, 'ids': state.ids};

  @override
  _ActiveTypes decodeState(JsonMap json) => (hostId: json['hostId'] as String, ids: (json['ids'] as List).cast());
}

final _view = View<_ActiveTypes?, HostSetupEvent>(
  initialState: null,
  evolve: (state, event) => switch (event) {
    MeetingTypeCreatedEvent(:final hostId, :final meetingTypeId) => (
      hostId: hostId.value,
      ids: [...?state?.ids, meetingTypeId.value],
    ),
    MeetingTypeDeletedEvent(:final meetingTypeId) when state != null => switch ([
      ...state.ids.where((id) => id != meetingTypeId.value),
    ]) {
      [] => null,
      final ids => (hostId: state.hostId, ids: ids),
    },
    _ => state,
  },
);

MeetingTypeCreatedEvent _created(String id) => MeetingTypeCreatedEvent(
  meetingTypeId: MeetingTypeId(id),
  hostId: HostId('alice'),
  meetingTitle: MeetingTitle('Chat'),
  durationMinutes: DurationMinutes(30),
  meetingLocation: MeetingLocation('Room 1'),
  scheduleId: ScheduleId('schedule-1'),
  bookingUrl: BookingUrl('http://x/book/$id'),
);

void main() {
  late InMemoryEventStore store;
  late ViewStateStore views;
  late InMemoryEventStreamer streamer;
  late _ActiveTypesRepository repository;

  setUp(() async {
    store = InMemoryEventStore(buildEventCatalog());
    views = InMemoryViewStateStore();
    streamer = InMemoryEventStreamer(store);
    repository = _ActiveTypesRepository(views);
    await streamer.start([
      materializedViewSubscription(
        view: _view,
        repository: repository,
        eventTypes: {MeetingTypeCreatedEvent, MeetingTypeDeletedEvent},
      ),
    ]);
  });

  // @ensures the document of a key folds every event of that key, also events found by a stream tag
  test('folds the events of a key into one document', () async {
    await store.append([_created('t1'), _created('t2')]);
    await store.append([MeetingTypeDeletedEvent(meetingTypeId: MeetingTypeId('t1'))]);
    await streamer.drain();
    final state = await repository.load('alice');
    expect(state?.hostId, 'alice');
    expect(state?.ids, ['t2']);
    expect(await repository.findWhere({'hostId': 'alice'}), hasLength(1));
  });

  // @ensures a state that evolves to null deletes its document
  test('deletes the document when the state becomes null', () async {
    await store.append([_created('t1')]);
    await store.append([MeetingTypeDeletedEvent(meetingTypeId: MeetingTypeId('t1'))]);
    await streamer.drain();
    expect(await repository.load('alice'), isNull);
  });
}
