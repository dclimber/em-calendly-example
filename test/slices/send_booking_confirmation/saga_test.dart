import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/send_booking_confirmation/confirmations_to_send/state.dart';
import 'package:em_calendly_example/slices/send_booking_confirmation/saga.dart';
import 'package:em_calendly_example/slices/send_booking_confirmation/send_booking_confirmation/command.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

ConfirmationToSendState _item({required bool ready, String meetingId = 'meeting-1'}) {
  final reserved = reservedEvent(meetingId: meetingId);
  return ConfirmationToSendState(
    meetingId: reserved.meetingId,
    meetingTitle: reserved.meetingTitle,
    meetingLocation: reserved.meetingLocation,
    slotStart: reserved.slotStart,
    slotEnd: reserved.slotEnd,
    participants: reserved.participants,
    ready: ready,
  );
}

void main() {
  // @requires a confirmed item that awaits its booking confirmation
  // @ensures scenario happy_path: the processor emits one send_booking_confirmation command for its meeting
  test('happy_path', () async {
    final commands = await confirmationSenderSaga.react(_item(ready: true)).toList();
    expect(commands, [
      SendBookingConfirmationCommand(meetingId: MeetingId('meeting-1'), participants: reservedEvent().participants),
    ]);
  });

  // @requires a reserved item that is not confirmed yet
  // @ensures the processor emits no command, so the confirmation waits for the meeting_confirmed event
  test('an unconfirmed item emits no command', () async {
    final commands = await confirmationSenderSaga.react(_item(ready: false)).toList();
    expect(commands, isEmpty);
  });

  // @requires any ready item, however many times it is processed
  // @ensures the processor emits exactly one command per item, and it names the same meeting
  test('exactly one command per ready item', () async {
    for (final id in ['meeting-1', 'meeting-2']) {
      final commands = await confirmationSenderSaga.react(_item(ready: true, meetingId: id)).toList();
      expect(commands, hasLength(1));
      expect(commands.single.meetingId, MeetingId(id));
    }
  });
}
