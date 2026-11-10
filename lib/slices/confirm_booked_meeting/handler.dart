import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/meetings/api.dart';
import '../../platform/event_store/event_store.dart';
import 'confirm_meeting/command.dart';
import 'confirm_meeting/errors.dart';
import 'created_calendar_events/view.dart';
import 'processor_state.dart';
import 'saga.dart';

/// Handles one `calendar_event_created` event: folds it into the created-events view, reads the calendar events its
/// meeting already recorded as confirmed, then runs the processor on the item that it lists.
///
/// Delivery is at least once. A redelivered calendar event is found in the recorded ids and sends no command. A
/// refused confirmation (the meeting left pending_calendar) is ignored.
Future<void> confirmBookedMeetingHandler(
  SagaManager<CalendarCreatedTranslatorInput, ConfirmMeetingCommand, NoMetadata, NoMetadata> processor,
  EventStore eventStore,
  StoredEvent stored,
) async {
  final item = createdCalendarEventsView.evolve(createdCalendarEventsView.initialState, stored.event);
  if (item == null) return;
  final history = await eventStore.read([
    (tag: 'meetingId', value: item.meetingId.value, eventTypes: const [MeetingConfirmedEvent]),
  ]);
  final recorded = history.events.fold(
    recordedCalendarEventsView.initialState,
    (state, event) => recordedCalendarEventsView.evolve(state, event.event as MeetingsEvent),
  );
  try {
    await processor.handle((recorded: recorded, item: item)).toList();
  } on ConfirmMeetingError {
    // The meeting is no longer pending_calendar: nothing to confirm.
  }
}
