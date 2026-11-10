import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/send_cancellation_notice/send_cancellation_notice/command.dart';
import 'package:em_calendly_example/slices/send_cancellation_notice/send_cancellation_notice/decider.dart';
import 'package:em_calendly_example/slices/send_cancellation_notice/send_cancellation_notice/errors.dart';
import 'package:em_calendly_example/slices/send_cancellation_notice/send_cancellation_notice/state.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

SendCancellationNoticeState _fold(List<MeetingsEvent> history) =>
    history.fold(sendCancellationNoticeDecider.initialState, sendCancellationNoticeDecider.evolve);

void main() {
  final reserved = reservedEvent();
  final command = SendCancellationNoticeCommand(meetingId: reserved.meetingId, participants: reserved.participants);

  // @requires a confirmed meeting that the scheduler canceled, and the cancellation is completed
  // @ensures scenario canceled_meeting_is_announced: the decider emits one cancellation_notice_sent
  test('canceled_meeting_is_announced', () async {
    final history = [reserved, confirmedEvent(), cancellationRequested(), canceled()];
    final events = await sendCancellationNoticeDecider.decide(command, _fold(history)).toList();
    expect(events, [noticeSent()]);
  });

  // @requires a canceled meeting whose cancellation_notice_sent was already recorded
  // @ensures scenario announced_cancellation_leaves_the_list: the decider refuses the repeat with no event
  test('announced_cancellation_leaves_the_list', () async {
    final history = [reserved, confirmedEvent(), cancellationRequested(), canceled(), noticeSent()];
    await expectLater(
      sendCancellationNoticeDecider.decide(command, _fold(history)).toList(),
      throwsA(isA<CancellationNoticeAlreadySentError>()),
    );
  });

  // @requires a confirmed meeting that was deleted directly in the calendar: no cancellation_requested event
  // @ensures scenario direct_deletion_is_announced: the decider emits one cancellation_notice_sent
  test('direct_deletion_is_announced', () async {
    final history = [reserved, confirmedEvent(), canceled()];
    final events = await sendCancellationNoticeDecider.decide(command, _fold(history)).toList();
    expect(events, [noticeSent()]);
  });

  // @requires a confirmed meeting that is not canceled
  // @ensures the decider refuses with MeetingNotCanceledForNoticeError, the transition has no other source state
  test('a meeting that is not canceled gets no notice', () async {
    final history = [reserved, confirmedEvent()];
    await expectLater(
      sendCancellationNoticeDecider.decide(command, _fold(history)).toList(),
      throwsA(isA<MeetingNotCanceledForNoticeError>()),
    );
  });

  // @requires a meeting that is canceling but not yet canceled
  // @ensures the decider refuses: the cancellation is not complete
  test('a canceling meeting gets no notice', () async {
    final history = [reserved, confirmedEvent(), cancellationRequested()];
    await expectLater(
      sendCancellationNoticeDecider.decide(command, _fold(history)).toList(),
      throwsA(isA<MeetingNotCanceledForNoticeError>()),
    );
  });

  // @requires any canceled meeting history
  // @ensures law idempotence: once the notice is folded, every later decision is refused and no event is emitted
  test('law: after the notice, every decision is refused', () async {
    final state = _fold([reserved, confirmedEvent(), canceled(), noticeSent(), noticeSent()]);
    expect(state.noticeSent, isTrue);
    await expectLater(
      sendCancellationNoticeDecider.decide(command, state).toList(),
      throwsA(isA<CancellationNoticeAlreadySentError>()),
    );
  });

  // @requires any history
  // @ensures law: evolve is pure, so folding the same history twice gives equal states
  test('law: folding the same history twice gives equal states', () {
    final history = [reserved, confirmedEvent(), cancellationRequested(), canceled(), noticeSent()];
    expect(_fold(history), _fold(history));
    expect(
      _fold(history),
      const SendCancellationNoticeState(lifecycle: MeetingLifecycleState.canceled, noticeSent: true),
    );
  });

  // @requires a canceled meeting with no notice
  // @ensures law: the decision leaves the notice state unchanged until the event is folded, and the event carries the participants
  test('law: the emitted event carries the command participants', () async {
    final state = _fold([reserved, confirmedEvent(), canceled()]);
    final events = await sendCancellationNoticeDecider.decide(command, state).toList();
    expect(events.single, isA<CancellationNoticeSentEvent>());
    expect((events.single as CancellationNoticeSentEvent).participants, reserved.participants);
    expect(_fold([reserved, confirmedEvent(), canceled()]).noticeSent, isFalse);
  });
}
