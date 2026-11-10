import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/request_calendar_event/request_calendar_event/command.dart';
import 'package:em_calendly_example/slices/request_calendar_event/reservations_awaiting_calendar_event/state.dart';
import 'package:em_calendly_example/slices/request_calendar_event/saga.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

ReservationAwaitingCalendarEventState _item({required bool verified, String meetingId = 'meeting-1'}) {
  final reserved = reservedEvent(meetingId: meetingId);
  return ReservationAwaitingCalendarEventState(
    meetingId: reserved.meetingId,
    hostId: reserved.hostId,
    meetingTitle: reserved.meetingTitle,
    meetingLocation: reserved.meetingLocation,
    slotStart: reserved.slotStart,
    slotEnd: reserved.slotEnd,
    participants: reserved.participants,
    verified: verified,
  );
}

void main() {
  // @requires a verified held slot that awaits its calendar event
  // @ensures scenario happy_path: the processor emits one request_calendar_event command for its meeting
  test('happy_path', () async {
    final commands = await calendarEventRequesterSaga.react(_item(verified: true)).toList();
    expect(commands, [RequestCalendarEventCommand(meetingId: MeetingId('meeting-1'))]);
  });

  // @requires a held slot that is not verified yet
  // @ensures the processor emits no command, so the calendar event waits for the verification
  test('an unverified slot emits no command', () async {
    final commands = await calendarEventRequesterSaga.react(_item(verified: false)).toList();
    expect(commands, isEmpty);
  });

  // @requires any verified held slot, however many times it is processed
  // @ensures the processor emits exactly one command, and it names the same meeting
  test('exactly one command per verified slot', () async {
    for (final id in ['meeting-1', 'meeting-2']) {
      final commands = await calendarEventRequesterSaga.react(_item(verified: true, meetingId: id)).toList();
      expect(commands, hasLength(1));
      expect(commands.single.meetingId, MeetingId(id));
    }
  });
}
