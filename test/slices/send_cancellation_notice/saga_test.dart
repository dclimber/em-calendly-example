import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/send_cancellation_notice/cancellation_notices_to_send/state.dart';
import 'package:em_calendly_example/slices/send_cancellation_notice/saga.dart';
import 'package:em_calendly_example/slices/send_cancellation_notice/send_cancellation_notice/command.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

CancellationNoticeToSendState _item({required bool ready}) => CancellationNoticeToSendState(
  meetingId: MeetingId('meeting-1'),
  meetingTitle: MeetingTitle('Intro call'),
  slotStart: SlotStart(DateTime.utc(2027, 3, 15, 9)),
  slotEnd: SlotEnd(DateTime.utc(2027, 3, 15, 9, 30)),
  participants: reservedEvent().participants,
  ready: ready,
);

void main() {
  // @requires a ready item of the to-do list
  // @ensures scenario canceled_meeting_is_announced (processor): the cancellation_notifier yields one command
  test('a ready item yields one send_cancellation_notice command', () async {
    final commands = await cancellationNotifierSaga.react(_item(ready: true)).toList();
    expect(commands, [
      SendCancellationNoticeCommand(meetingId: MeetingId('meeting-1'), participants: reservedEvent().participants),
    ]);
  });

  // @requires an item that is not ready
  // @ensures the processor yields nothing: expect_no_dispatch
  test('an item that is not ready yields no command', () async {
    expect(await cancellationNotifierSaga.react(_item(ready: false)).toList(), isEmpty);
  });
}
