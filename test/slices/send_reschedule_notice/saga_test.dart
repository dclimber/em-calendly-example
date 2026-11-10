import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/send_reschedule_notice/reschedule_notices_to_send/state.dart';
import 'package:em_calendly_example/slices/send_reschedule_notice/saga.dart';
import 'package:em_calendly_example/slices/send_reschedule_notice/send_reschedule_notice/command.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

RescheduleNoticeToSendState _item({required bool ready}) => RescheduleNoticeToSendState(
  meetingId: MeetingId('meeting-1'),
  meetingTitle: MeetingTitle('Intro call'),
  newSlotStart: NewSlotStart(rescheduleStart),
  newSlotEnd: NewSlotEnd(rescheduleEnd),
  participants: reservedEvent().participants,
  ready: ready,
);

void main() {
  // @requires a ready item of the to-do list
  // @ensures scenario completed_reschedule_is_announced (processor): the reschedule_notifier yields one command for the new slot
  test('a ready item yields one send_reschedule_notice command', () async {
    final commands = await rescheduleNotifierSaga.react(_item(ready: true)).toList();
    expect(commands, [
      SendRescheduleNoticeCommand(
        meetingId: MeetingId('meeting-1'),
        newSlotStart: NewSlotStart(rescheduleStart),
        participants: reservedEvent().participants,
      ),
    ]);
  });

  // @requires an item that is not ready
  // @ensures the processor yields nothing: expect_no_dispatch
  test('an item that is not ready yields no command', () async {
    expect(await rescheduleNotifierSaga.react(_item(ready: false)).toList(), isEmpty);
  });
}
