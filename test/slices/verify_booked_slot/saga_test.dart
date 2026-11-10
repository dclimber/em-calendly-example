import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/verify_booked_slot/free_answers_for_bookings/state.dart';
import 'package:em_calendly_example/slices/verify_booked_slot/saga.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  // @requires a listed free answer for a meeting
  // @ensures scenario translator_records_the_verification: the processor emits one record_booking_slot_verified command
  test('translator_records_the_verification', () async {
    final commands = await bookingFreeTranslatorSaga
        .react(FreeAnswerForBookingState(meetingId: MeetingId('meeting-1')))
        .toList();
    expect(commands, [commandFor('meeting-1')]);
  });

  // @requires any listed free answer, however many times it is processed
  // @ensures the processor emits exactly one command, and it names the same meeting
  test('exactly one command per listed answer', () async {
    for (final id in ['meeting-1', 'meeting-2']) {
      final commands = await bookingFreeTranslatorSaga
          .react(FreeAnswerForBookingState(meetingId: MeetingId(id)))
          .toList();
      expect(commands, hasLength(1));
      expect(commands.single.meetingId, MeetingId(id));
    }
  });
}
