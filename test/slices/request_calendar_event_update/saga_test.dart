import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/request_calendar_event_update/request_calendar_event_update/command.dart';
import 'package:em_calendly_example/slices/request_calendar_event_update/reschedules_awaiting_calendar_update/state.dart';
import 'package:em_calendly_example/slices/request_calendar_event_update/saga.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

ReschedulesAwaitingCalendarUpdateState _item({required bool verified, String meetingId = 'meeting-1'}) {
  final requested = rescheduleRequestedEvent(meetingId: meetingId);
  return ReschedulesAwaitingCalendarUpdateState(
    meetingId: requested.meetingId,
    newSlotStart: requested.newSlotStart,
    newSlotEnd: requested.newSlotEnd,
    calendarEventId: requested.calendarEventId,
    verified: verified,
  );
}

void main() {
  // @requires a verified reschedule that awaits its calendar update
  // @ensures scenario reschedule_requests_a_calendar_update: the processor emits one request for its meeting and new slot
  test('reschedule_requests_a_calendar_update', () async {
    final commands = await calendarUpdateRequesterSaga.react(_item(verified: true)).toList();
    expect(commands, [
      RequestCalendarEventUpdateCommand(
        meetingId: MeetingId('meeting-1'),
        newSlotStart: NewSlotStart(DateTime.utc(2027, 3, 16, 14)),
      ),
    ]);
  });

  // @requires a reschedule whose new slot is not verified yet
  // @ensures the processor emits no command, so the calendar update waits for the verification
  test('an unverified reschedule emits no command', () async {
    final commands = await calendarUpdateRequesterSaga.react(_item(verified: false)).toList();
    expect(commands, isEmpty);
  });

  // @requires any verified reschedule, however many times it is processed
  // @ensures the processor emits exactly one command, and it names the same meeting
  test('exactly one command per verified reschedule', () async {
    for (final id in ['meeting-1', 'meeting-2']) {
      final commands = await calendarUpdateRequesterSaga.react(_item(verified: true, meetingId: id)).toList();
      expect(commands, hasLength(1));
      expect(commands.single.meetingId, MeetingId(id));
    }
  });
}
