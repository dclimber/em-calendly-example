import 'package:fmodel/fmodel.dart';

import '../../bounded_contexts/meetings/api.dart';
import '../../composition/app_services.dart';
import '../../platform/event_store/event_store.dart';
import '../../platform/mail/mailer.dart';
import '../../ui/paths.dart';
import 'confirmations_to_send/repository.dart';
import 'confirmations_to_send/state.dart';
import 'confirmations_to_send/view.dart';
import 'send_booking_confirmation/command.dart';
import 'send_booking_confirmation/errors.dart';
import 'send_booking_confirmation/service.dart';

/// Handles one `meeting_slot_reserved`, `meeting_confirmed`, or `booking_confirmation_sent` event: folds it into the
/// to-do list. When the item is ready, it checks with a dry run that the decider would accept the send, sends ONE
/// email to both participants, then handles the command.
///
/// Delivery is at least once. The dry run stops a redelivery before the email, and a repeated command is refused by
/// the decider, which the handler ignores.
Future<void> sendBookingConfirmationHandler(
  SagaManager<ConfirmationToSendState, SendBookingConfirmationCommand, NoMetadata, NoMetadata> processor,
  ConfirmationsToSendRepository repository,
  SendBookingConfirmationService service,
  AppServices services,
  StoredEvent stored,
) async {
  final view = createMaterializedView<ConfirmationToSendState?, StoredEvent, NoMetadata>(
    view: confirmationsToSendView.mapLeftOnEvent<StoredEvent>((s) => s.event as MeetingsEvent),
    viewStateRepository: repository,
  );
  final item = await view.handle(stored);
  // The view deletes the item for the sent event, and it lists an item only once its meeting is confirmed.
  if (item == null || !item.ready) return;
  final command = SendBookingConfirmationCommand(meetingId: item.meetingId, participants: item.participants);
  if (!await service.canSend(command)) return;

  final start = item.slotStart.value.toUtc().toIso8601String();
  final end = item.slotEnd.value.toUtc().toIso8601String();
  await services.mailer.send(
    EmailMessage(
      to: [for (final p in item.participants.items) p.email.value],
      subject: 'Meeting confirmed: ${item.meetingTitle.value}',
      text: [
        item.meetingTitle.value,
        'Start: $start',
        'End: $end',
        'Location: ${item.meetingLocation.value}',
        services.absoluteUrl(meetingDetails(item.meetingId.value)),
      ].join('\n'),
    ),
  );

  try {
    await processor.handle(item).toList();
  } on SendBookingConfirmationError {
    // The confirmation was already sent, or the meeting left confirmed: nothing to do.
  }
}
