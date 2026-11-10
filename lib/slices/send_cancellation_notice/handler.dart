import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/meetings/api.dart';
import '../../composition/app_services.dart';
import '../../platform/event_store/event_store.dart';
import '../../platform/mail/mailer.dart';
import 'cancellation_notices_to_send/repository.dart';
import 'cancellation_notices_to_send/state.dart';
import 'cancellation_notices_to_send/view.dart';
import 'send_cancellation_notice/command.dart';
import 'send_cancellation_notice/errors.dart';
import 'send_cancellation_notice/service.dart';

/// Handles one reservation, cancellation, or notice event: folds it into the to-do list. When the item is ready, it
/// checks with a dry run that the decider would accept the notice, sends ONE email to every participant, then handles
/// the command.
///
/// Delivery is at least once. The dry run stops a redelivery before the email, and a repeated notice is refused by the
/// decider, which the handler ignores.
Future<void> sendCancellationNoticeHandler(
  SagaManager<CancellationNoticeToSendState, SendCancellationNoticeCommand, NoMetadata, NoMetadata> processor,
  CancellationNoticesToSendRepository repository,
  SendCancellationNoticeService service,
  AppServices services,
  StoredEvent stored,
) async {
  final view = createMaterializedView<CancellationNoticeToSendState?, StoredEvent, NoMetadata>(
    view: cancellationNoticesToSendView.mapLeftOnEvent<StoredEvent>((s) => s.event as MeetingsEvent),
    viewStateRepository: repository,
  );
  final item = await view.handle(stored);
  if (item == null || !item.ready) return;
  final command = SendCancellationNoticeCommand(meetingId: item.meetingId, participants: item.participants);
  if (!await service.canSend(command)) return;

  final start = item.slotStart.value.toUtc().toIso8601String();
  await services.mailer.send(
    EmailMessage(
      to: [for (final p in item.participants.items) p.email.value],
      subject: 'Meeting canceled: ${item.meetingTitle.value}',
      text: [item.meetingTitle.value, 'Start: $start'].join('\n'),
    ),
  );

  try {
    await processor.handle(item).toList();
  } on SendCancellationNoticeError {
    // The notice was already sent, or the meeting is not canceled: nothing to do.
  }
}
