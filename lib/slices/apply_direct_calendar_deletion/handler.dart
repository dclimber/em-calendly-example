import 'package:fmodel/fmodel.dart';

import '../../platform/event_store/event_store.dart';
import 'direct_calendar_deletions/view.dart';
import 'record_meeting_deleted/command.dart';
import 'record_meeting_deleted/errors.dart';
import 'record_meeting_deleted/service.dart';
import 'saga.dart';

/// Handles one `calendar_event_deleted_directly` event: lists its meeting in the view, reads the meeting's lifecycle as
/// the processor history, then runs the processor on that item.
///
/// The decider's sealed errors are the model's refusals (ended, not confirmed); the handler ignores them.
Future<void> recordMeetingDeletedHandler(
  EventStore eventStore,
  SagaManager<DirectDeletionInput, RecordMeetingDeletedCommand, NoMetadata, NoMetadata> processor,
  StoredEvent stored,
) async {
  final deletion = directCalendarDeletionsView.evolve(directCalendarDeletionsView.initialState, stored.event);
  if (deletion == null) return;
  final history = await RecordMeetingDeletedService(eventStore: eventStore).loadLifecycle(deletion.meetingId);
  try {
    await processor.handle((deletion: deletion, history: history)).toList();
  } on RecordMeetingDeletedError {
    // The meeting cannot take a direct deletion now (ended or not confirmed): the calendar keeps its deletion.
  }
}
