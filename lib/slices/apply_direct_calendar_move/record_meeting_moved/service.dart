import '../../../bounded_contexts/meetings/api.dart';
import '../../../platform/event_store/consistent_event_repository.dart';
import '../../../platform/event_store/event_store.dart';
import 'aggregate.dart';
import 'command.dart';
import 'repository.dart';
import 'state.dart';

/// Handles `record_meeting_moved` on the `meeting` aggregate.
final class RecordMeetingMovedService {
  RecordMeetingMovedService({required EventStore eventStore}) : _eventStore = eventStore;

  final EventStore _eventStore;

  /// Handles the command with a fresh repository, and retries when another writer changed the meeting's history.
  Future<List<MeetingsEvent>> handle(RecordMeetingMovedCommand command) => handleCommand(
    () => buildRecordMeetingMovedAggregate(repository: RecordMeetingMovedEventRepository(_eventStore)),
    command,
  );

  /// The lifecycle of the meeting as its `meeting` events fold it: the processor history of `direct_move_translator`.
  Future<RecordMeetingMovedState> loadLifecycle(MeetingId meetingId) async {
    final read = await _eventStore.read([
      (tag: 'meetingId', value: meetingId.value, eventTypes: meetingLifecycleEventTypes),
    ]);
    var state = meetingLifecycleView.initialState;
    for (final stored in read.events) {
      state = meetingLifecycleView.evolve(state, stored.event as MeetingsEvent);
    }
    return state;
  }
}
