import 'package:fmodel/fmodel.dart';

import '../../platform/event_store/event_store.dart';
import 'direct_calendar_moves/view.dart';
import 'record_meeting_moved/command.dart';
import 'record_meeting_moved/errors.dart';
import 'record_meeting_moved/service.dart';
import 'saga.dart';

/// Handles one `calendar_event_moved_directly` event: lists its meeting in the view, reads the meeting's lifecycle as
/// the processor history, then runs the processor on that item.
///
/// The decider's sealed errors are the model's refusals (canceling, ended, not confirmed); the handler ignores them.
Future<void> recordMeetingMovedHandler(
  EventStore eventStore,
  SagaManager<DirectMoveInput, RecordMeetingMovedCommand, NoMetadata, NoMetadata> processor,
  StoredEvent stored,
) async {
  final move = directCalendarMovesView.evolve(directCalendarMovesView.initialState, stored.event);
  if (move == null) return;
  final history = await RecordMeetingMovedService(eventStore: eventStore).loadLifecycle(move.meetingId);
  try {
    await processor.handle((move: move, history: history)).toList();
  } on RecordMeetingMovedError {
    // The meeting cannot take a direct move now (canceling, ended, or not confirmed): the calendar keeps its move.
  }
}
