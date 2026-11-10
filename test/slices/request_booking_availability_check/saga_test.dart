import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/request_booking_availability_check/reservations_awaiting_live_check/state.dart';
import 'package:em_calendly_example/slices/request_booking_availability_check/saga.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  final reserved = reservedEvent();
  final item = ReservationAwaitingLiveCheckState(
    meetingId: reserved.meetingId,
    hostId: reserved.hostId,
    slotStart: reserved.slotStart,
    slotEnd: reserved.slotEnd,
  );

  // @requires a held slot that awaits its live check
  // @ensures scenario check_is_requested: the processor emits one request_booking_availability_check command
  test('check_is_requested', () async {
    final commands = await bookingCheckRequesterSaga.react(item).toList();
    expect(commands, [commandFor(reserved)]);
  });

  // @requires any held slot, however many times it is processed
  // @ensures the processor emits exactly one command, and it names the same meeting, host, and slot
  test('exactly one command per held slot', () async {
    final items = [
      item,
      ReservationAwaitingLiveCheckState(
        meetingId: MeetingId('meeting-2'),
        hostId: HostId('bob-employee-id'),
        slotStart: SlotStart(DateTime.utc(2027, 4, 1, 14)),
        slotEnd: SlotEnd(DateTime.utc(2027, 4, 1, 15)),
      ),
    ];
    for (final held in items) {
      final commands = await bookingCheckRequesterSaga.react(held).toList();
      expect(commands, hasLength(1));
      expect(commands.single.meetingId, held.meetingId);
      expect(commands.single.hostId, held.hostId);
      expect(commands.single.slotStart, held.slotStart);
      expect(commands.single.slotEnd, held.slotEnd);
    }
  });
}
