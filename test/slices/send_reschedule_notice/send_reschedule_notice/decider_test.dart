import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/send_reschedule_notice/send_reschedule_notice/command.dart';
import 'package:em_calendly_example/slices/send_reschedule_notice/send_reschedule_notice/decider.dart';
import 'package:em_calendly_example/slices/send_reschedule_notice/send_reschedule_notice/errors.dart';
import 'package:em_calendly_example/slices/send_reschedule_notice/send_reschedule_notice/state.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

SendRescheduleNoticeState _fold(List<MeetingsEvent> history) =>
    history.fold(sendRescheduleNoticeDecider.initialState, sendRescheduleNoticeDecider.evolve);

void main() {
  final reserved = reservedEvent();
  final command = SendRescheduleNoticeCommand(
    meetingId: reserved.meetingId,
    newSlotStart: NewSlotStart(rescheduleStart),
    participants: reserved.participants,
  );

  // @requires a confirmed meeting that is rescheduled to a new time, and the reschedule is completed
  // @ensures scenario completed_reschedule_is_announced: the decider emits one reschedule_notice_sent for the new time
  test('completed_reschedule_is_announced', () async {
    final history = [reserved, confirmedEvent(), rescheduleRequested(), rescheduled()];
    final events = await sendRescheduleNoticeDecider.decide(command, _fold(history)).toList();
    expect(events, [noticeSent()]);
  });

  // @requires a confirmed meeting that was moved directly in the calendar
  // @ensures scenario direct_move_is_announced: the decider emits one reschedule_notice_sent for the moved time
  test('direct_move_is_announced', () async {
    final moved = movedInCalendar();
    final moveCommand = SendRescheduleNoticeCommand(
      meetingId: reserved.meetingId,
      newSlotStart: moved.newSlotStart,
      participants: reserved.participants,
    );
    final history = [reserved, confirmedEvent(), moved];
    final events = await sendRescheduleNoticeDecider.decide(moveCommand, _fold(history)).toList();
    expect(events, [noticeSent(start: DateTime.utc(2027, 3, 15, 11))]);
  });

  // @requires a meeting that is still rescheduling (the reschedule is not completed)
  // @ensures the decider refuses the notice with MeetingNotConfirmedForNoticeError, and emits nothing
  test('a meeting that is still rescheduling is refused', () async {
    await expectLater(
      sendRescheduleNoticeDecider.decide(command, _fold([reserved, confirmedEvent(), rescheduleRequested()])).toList(),
      throwsA(isA<MeetingNotConfirmedForNoticeError>()),
    );
  });

  // @requires a meeting that is reserved but not confirmed
  // @ensures the decider refuses the notice with MeetingNotConfirmedForNoticeError, and emits nothing
  test('a meeting that is not confirmed is refused', () async {
    await expectLater(
      sendRescheduleNoticeDecider.decide(command, _fold([reserved])).toList(),
      throwsA(isA<MeetingNotConfirmedForNoticeError>()),
    );
  });

  // @requires a completed reschedule whose notice for the same new time was already sent
  // @ensures the decider refuses the repeat with RescheduleNoticeAlreadySentError, and emits nothing
  test('a repeated notice for the same new time is refused', () async {
    final history = [reserved, confirmedEvent(), rescheduleRequested(), rescheduled(), noticeSent()];
    await expectLater(
      sendRescheduleNoticeDecider.decide(command, _fold(history)).toList(),
      throwsA(isA<RescheduleNoticeAlreadySentError>()),
    );
  });

  // @requires a notice sent for one new time, then a later, different reschedule to another new time
  // @ensures the later reschedule gets its own notice: the decider emits one event for the new time
  test('a later, different reschedule gets its own notice', () async {
    final later = rescheduleRequested(start: DateTime.utc(2027, 3, 15, 12), end: DateTime.utc(2027, 3, 15, 12, 30));
    final history = [
      reserved,
      confirmedEvent(),
      rescheduleRequested(),
      rescheduled(),
      noticeSent(),
      later,
      rescheduled(),
    ];
    final laterCommand = SendRescheduleNoticeCommand(
      meetingId: reserved.meetingId,
      newSlotStart: later.newSlotStart,
      participants: reserved.participants,
    );
    final events = await sendRescheduleNoticeDecider.decide(laterCommand, _fold(history)).toList();
    expect(events, [noticeSent(start: DateTime.utc(2027, 3, 15, 12))]);
  });

  // @requires a notice that was sent
  // @ensures the state stays confirmed after the notice, and records the new slot start that was announced
  test('sending keeps the meeting confirmed and records the announced time', () {
    final state = _fold([reserved, confirmedEvent(), rescheduleRequested(), rescheduled(), noticeSent()]);
    expect(state.lifecycle, MeetingLifecycleState.confirmed);
    expect(state.lastNoticedNewSlotStart, NewSlotStart(rescheduleStart));
  });

  // @requires the decider's state folded from any history
  // @ensures law: folding the same history twice yields equal states (the fold is deterministic)
  test('law: folding a history is deterministic', () {
    final history = [reserved, confirmedEvent(), rescheduleRequested(), rescheduled(), noticeSent()];
    expect(_fold(history), _fold(history));
    expect(_fold(history), isA<SendRescheduleNoticeState>());
  });

  // @requires a confirmed meeting with no notice sent
  // @ensures law: a successful decision yields exactly one event, and it is a reschedule_notice_sent for the command's meeting
  test('law: a successful decision emits exactly one notice for the command meeting', () async {
    final events = await sendRescheduleNoticeDecider
        .decide(command, _fold([reserved, confirmedEvent(), rescheduleRequested(), rescheduled()]))
        .toList();
    expect(events, hasLength(1));
    expect(events.single, isA<RescheduleNoticeSentEvent>());
    expect((events.single as RescheduleNoticeSentEvent).meetingId, command.meetingId);
  });
}
