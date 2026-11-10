import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/meetings/api.dart';
import '../../composition/app_services.dart';
import '../../platform/event_store/event_store.dart';
import '../../platform/mail/mailer.dart';
import '../../ui/paths.dart';
import 'reschedule_notices_to_send/repository.dart';
import 'reschedule_notices_to_send/state.dart';
import 'reschedule_notices_to_send/view.dart';
import 'send_reschedule_notice/command.dart';
import 'send_reschedule_notice/errors.dart';
import 'send_reschedule_notice/service.dart';

/// Handles one reschedule or direct-move event: folds it into the to-do list. When the item is ready, it checks with a
/// dry run that the decider would accept the notice, sends ONE email to every participant, then handles the command.
///
/// Delivery is at least once. The dry run stops a redelivery before the email, and a repeated new time is refused by
/// the decider, which the handler ignores.
Future<void> sendRescheduleNoticeHandler(
  SagaManager<RescheduleNoticeToSendState, SendRescheduleNoticeCommand, NoMetadata, NoMetadata> processor,
  RescheduleNoticesToSendRepository repository,
  SendRescheduleNoticeService service,
  AppServices services,
  StoredEvent stored,
) async {
  final view = createMaterializedView<RescheduleNoticeToSendState?, StoredEvent, NoMetadata>(
    view: rescheduleNoticesToSendView.mapLeftOnEvent<StoredEvent>((s) => s.event as MeetingsEvent),
    viewStateRepository: repository,
  );
  final item = await view.handle(stored);
  if (item == null || !item.ready) return;
  final command = SendRescheduleNoticeCommand(
    meetingId: item.meetingId,
    newSlotStart: item.newSlotStart,
    participants: item.participants,
  );
  if (!await service.canSend(command)) return;

  final title = item.meetingTitle?.value ?? await _reservedTitle(services.eventStore, item.meetingId);
  final start = item.newSlotStart.value.toUtc().toIso8601String();
  final end = item.newSlotEnd.value.toUtc().toIso8601String();
  await services.mailer.send(
    EmailMessage(
      to: [for (final p in item.participants.items) p.email.value],
      subject: 'Meeting rescheduled: $title',
      text: [
        title,
        'Start: $start',
        'End: $end',
        services.absoluteUrl(meetingDetails(item.meetingId.value)),
      ].join('\n'),
    ),
  );

  try {
    await processor.handle(item).toList();
  } on SendRescheduleNoticeError {
    // The notice for this new time was already sent, or the meeting left confirmed: nothing to do.
  }
}

/// The title of a meeting, from its `meeting_slot_reserved` event. The to-do item has no title when a reschedule was
/// folded without its reservation; every meeting has one, so a missing reservation is an error.
Future<String> _reservedTitle(EventStore eventStore, MeetingId meetingId) async {
  final read = await eventStore.read([
    (tag: 'meetingId', value: meetingId.value, eventTypes: const [MeetingSlotReservedEvent]),
  ]);
  final reserved = read.events.map((stored) => stored.event).whereType<MeetingSlotReservedEvent>();
  if (reserved.isEmpty) {
    throw StateError('The meeting ${meetingId.value} has no meeting_slot_reserved event.');
  }
  return reserved.first.meetingTitle.value;
}
