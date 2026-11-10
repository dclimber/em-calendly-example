import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/request_reschedule_availability_check/reschedules_awaiting_live_check/state.dart';
import 'package:em_calendly_example/slices/request_reschedule_availability_check/saga.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  final requested = rescheduleRequestedEvent();
  final item = RescheduleAwaitingLiveCheckState(
    meetingId: requested.meetingId,
    hostId: requested.hostId,
    newSlotStart: requested.newSlotStart,
    newSlotEnd: requested.newSlotEnd,
  );

  // @requires a requested new time that awaits its live check
  // @ensures scenario check_is_requested: the processor emits one request_reschedule_availability_check command
  test('check_is_requested', () async {
    final commands = await rescheduleCheckRequesterSaga.react(item).toList();
    expect(commands, [commandFor(requested)]);
  });

  // @requires any requested new time, however many times it is processed
  // @ensures the processor emits exactly one command, and it names the same meeting, host, and new slot
  test('exactly one command per requested new time', () async {
    final items = [
      item,
      RescheduleAwaitingLiveCheckState(
        meetingId: MeetingId('meeting-2'),
        hostId: HostId('bob-employee-id'),
        newSlotStart: NewSlotStart(DateTime.utc(2027, 4, 1, 14)),
        newSlotEnd: NewSlotEnd(DateTime.utc(2027, 4, 1, 15)),
      ),
    ];
    for (final requestedItem in items) {
      final commands = await rescheduleCheckRequesterSaga.react(requestedItem).toList();
      expect(commands, hasLength(1));
      expect(commands.single.meetingId, requestedItem.meetingId);
      expect(commands.single.hostId, requestedItem.hostId);
      expect(commands.single.newSlotStart, requestedItem.newSlotStart);
      expect(commands.single.newSlotEnd, requestedItem.newSlotEnd);
    }
  });
}
