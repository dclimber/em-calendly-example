import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/send_booking_confirmation/send_booking_confirmation/command.dart';
import 'package:em_calendly_example/slices/send_booking_confirmation/send_booking_confirmation/decider.dart';
import 'package:em_calendly_example/slices/send_booking_confirmation/send_booking_confirmation/errors.dart';
import 'package:em_calendly_example/slices/send_booking_confirmation/send_booking_confirmation/state.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

SendBookingConfirmationState _fold(List<MeetingsEvent> history) =>
    history.fold(sendBookingConfirmationDecider.initialState, sendBookingConfirmationDecider.evolve);

void main() {
  final reserved = reservedEvent();
  final command = SendBookingConfirmationCommand(meetingId: reserved.meetingId, participants: reserved.participants);

  // @requires a confirmed meeting whose booking confirmation was not sent yet
  // @ensures scenario confirmed_meeting_is_announced: the decider emits one booking_confirmation_sent for the meeting
  test('confirmed_meeting_is_announced', () async {
    final events = await sendBookingConfirmationDecider.decide(command, _fold([reserved, confirmedEvent()])).toList();
    expect(events, [sentEvent()]);
  });

  // @requires a meeting that is reserved but not confirmed
  // @ensures the decider refuses the send with MeetingNotConfirmedError, and emits nothing
  test('a meeting that is not confirmed is refused', () async {
    await expectLater(
      sendBookingConfirmationDecider.decide(command, _fold([reserved])).toList(),
      throwsA(isA<MeetingNotConfirmedError>()),
    );
  });

  // @requires a confirmed meeting whose booking confirmation was already sent
  // @ensures the decider refuses the repeat with BookingConfirmationAlreadySentError, and emits nothing
  test('a repeated send is refused', () async {
    final history = [reserved, confirmedEvent(), sentEvent()];
    await expectLater(
      sendBookingConfirmationDecider.decide(command, _fold(history)).toList(),
      throwsA(isA<BookingConfirmationAlreadySentError>()),
    );
  });

  // @requires a confirmed meeting that is sent once
  // @ensures the state stays confirmed after the send, and the send is then the only refusal
  test('sending keeps the meeting confirmed', () {
    final state = _fold([reserved, confirmedEvent(), sentEvent()]);
    expect(state.lifecycle, MeetingLifecycleState.confirmed);
    expect(state.bookingConfirmationSent, isTrue);
  });

  // @requires a booking that failed before confirmation
  // @ensures the decider refuses the send, because the meeting is not confirmed
  test('a failed booking is refused', () async {
    final failed = MeetingBookingFailedEvent(
      meetingId: reserved.meetingId,
      failureReason: FailureReason('calendar busy'),
    );
    await expectLater(
      sendBookingConfirmationDecider.decide(command, _fold([reserved, failed])).toList(),
      throwsA(isA<MeetingNotConfirmedError>()),
    );
  });

  // @requires any confirmed meeting, folded any number of times
  // @ensures the event emitted carries the command's meeting and participants, and the decider is deterministic
  test('the emitted event names the command meeting and participants', () async {
    final history = _fold([reserved, confirmedEvent()]);
    final first = await sendBookingConfirmationDecider.decide(command, history).toList();
    final second = await sendBookingConfirmationDecider.decide(command, history).toList();
    expect(first, second);
    final sent = first.single as BookingConfirmationSentEvent;
    expect(sent.meetingId, command.meetingId);
    expect(sent.participants, command.participants);
  });
}
