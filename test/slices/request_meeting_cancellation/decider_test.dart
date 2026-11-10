import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';
import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/request_meeting_cancellation/command.dart';
import 'package:em_calendly_example/slices/request_meeting_cancellation/decider.dart';
import 'package:em_calendly_example/slices/request_meeting_cancellation/errors.dart';
import 'package:em_calendly_example/slices/request_meeting_cancellation/state.dart';
import 'package:test/test.dart';

final _host = HostId('alice-employee-id');
final _booker = BookerId('carol-employee-id');
final _stranger = RequestedBy('dave-employee-id');
final _meeting = MeetingId('meeting-1');
final _slotStart = DateTime.utc(2027, 3, 22, 9);
final _slotEnd = DateTime.utc(2027, 3, 22, 9, 30);

/// A reserved meeting of the host with [_booker], in the slot [_slotStart] to [_slotEnd].
MeetingSlotReservedEvent _reserved() => MeetingSlotReservedEvent(
  meetingId: _meeting,
  hostId: _host,
  bookerId: _booker,
  meetingTypeId: MeetingTypeId('meeting-type-1'),
  meetingTitle: MeetingTitle('30-minute consultation'),
  meetingLocation: MeetingLocation('Video call'),
  slotStart: SlotStart(_slotStart),
  slotEnd: SlotEnd(_slotEnd),
  participants: Participants([
    Participant(
      employeeId: EmployeeId(_host.value),
      name: EmployeeName('Alice'),
      email: EmployeeEmail('alice@example.com'),
      role: 'host',
    ),
    Participant(
      employeeId: EmployeeId(_booker.value),
      name: EmployeeName('Carol'),
      email: EmployeeEmail('carol@example.com'),
      role: 'booker',
    ),
  ]),
);

/// The `meeting_confirmed` history: a reserved and confirmed meeting.
final _confirmed = <DomainEvent>[
  _reserved(),
  MeetingConfirmedEvent(meetingId: _meeting, calendarEventId: CalendarEventId('evt-1')),
];

RequestMeetingCancellationCommand _cancel({RequestedBy? requestedBy, MeetingId? meetingId}) =>
    RequestMeetingCancellationCommand(
      meetingId: meetingId ?? _meeting,
      requestedBy: requestedBy ?? RequestedBy(_booker.value),
    );

CancellationState _fold(List<DomainEvent> history) =>
    history.fold(requestMeetingCancellationDecider.initialState, requestMeetingCancellationDecider.evolve);

Future<List<DomainEvent>> _decide(RequestMeetingCancellationCommand command, List<DomainEvent> history) =>
    requestMeetingCancellationDecider.decide(command, _fold(history)).toList();

void main() {
  group('happy_path', () {
    test('participant_requests_cancellation: the booker cancels a confirmed meeting', () async {
      final emitted = await _decide(_cancel(), _confirmed);

      expect(emitted, [
        isA<MeetingCancellationRequestedEvent>()
            .having((e) => e.meetingId, 'meetingId', _meeting)
            .having((e) => e.hostId, 'hostId', _host)
            .having((e) => e.requestedBy.value, 'requestedBy', _booker.value)
            .having((e) => e.calendarEventId.value, 'calendarEventId', 'evt-1')
            .having((e) => e.participants.items.length, 'participants', 2),
      ]);
    });

    test('the host may request the cancellation as well', () async {
      final emitted = await _decide(_cancel(requestedBy: RequestedBy(_host.value)), _confirmed);

      expect(emitted.single, isA<MeetingCancellationRequestedEvent>());
    });
  });

  group('state_violation', () {
    for (final ended in [
      ('canceled_meeting_cannot_be_canceled_again', MeetingCanceledEvent(meetingId: _meeting)),
      ('completed_meeting_cannot_be_canceled', MeetingCompletedEvent(meetingId: _meeting)),
      (
        'booking_failed_meeting_cannot_be_canceled',
        MeetingBookingFailedEvent(meetingId: _meeting, failureReason: FailureReason('calendar down')),
      ),
    ]) {
      test(ended.$1, () async {
        await expectLater(_decide(_cancel(), [..._confirmed, ended.$2]), throwsA(isA<MeetingEndedError>()));
      });
    }

    test('cancellation_waits_for_a_running_change: a meeting in rescheduling is refused', () async {
      await expectLater(
        _decide(_cancel(), [
          ..._confirmed,
          MeetingRescheduleRequestedEvent(
            meetingId: _meeting,
            hostId: _host,
            requestedBy: RequestedBy(_booker.value),
            newSlotStart: NewSlotStart(_slotStart.add(const Duration(hours: 1))),
            newSlotEnd: NewSlotEnd(_slotEnd.add(const Duration(hours: 1))),
            calendarEventId: CalendarEventId('evt-1'),
            participants: Participants.empty(),
          ),
        ]),
        throwsA(isA<ChangeInProgressError>()),
      );
    });

    test('a meeting still pending in the calendar refuses a cancellation', () async {
      await expectLater(_decide(_cancel(), [_reserved()]), throwsA(isA<ChangeInProgressError>()));
    });

    test('a meeting already canceling refuses a second cancellation', () async {
      await expectLater(
        _decide(_cancel(), [
          ..._confirmed,
          MeetingCancellationRequestedEvent(
            meetingId: _meeting,
            hostId: _host,
            requestedBy: RequestedBy(_booker.value),
            calendarEventId: CalendarEventId('evt-1'),
            participants: Participants.empty(),
          ),
        ]),
        throwsA(isA<ChangeInProgressError>()),
      );
    });
  });

  group('authorization', () {
    test('non_participant_is_refused: a stranger cannot cancel a confirmed meeting', () async {
      await expectLater(
        _decide(_cancel(requestedBy: _stranger), _confirmed),
        throwsA(
          isA<NotAParticipantError>().having(
            (e) => e.message,
            'message',
            'Only the participants of this meeting can change it.',
          ),
        ),
      );
    });

    test('a meeting that was never reserved has no participants', () async {
      await expectLater(_decide(_cancel(), const []), throwsA(isA<NotAParticipantError>()));
    });
  });

  group('exact_messages', () {
    test('the refusals carry the text of the model', () {
      expect(const MeetingEndedError().message, 'A meeting that has ended or was canceled cannot be canceled.');
      expect(const ChangeInProgressError().message, 'Another change to this meeting is still in progress.');
      expect(const NotAParticipantError().message, 'Only the participants of this meeting can change it.');
    });
  });

  group('laws', () {
    // @requires: the meeting is confirmed and the requester is a participant.
    // @ensures: the emitted event names the requester, the host, the calendar event, and every participant of the stream.
    test('a granted cancellation copies the facts of the stream', () async {
      for (final requester in [_booker.value, _host.value]) {
        final emitted = await _decide(_cancel(requestedBy: RequestedBy(requester)), _confirmed);
        final event = emitted.single as MeetingCancellationRequestedEvent;
        expect(event.requestedBy.value, requester);
        expect(event.hostId, _host);
        expect(event.calendarEventId.value, 'evt-1');
        expect(event.participants, _reserved().participants);
      }
    });

    // @requires: any history.
    // @ensures: a refused command emits no event, and the same command on the same history gives the same result.
    test('a refused decision is deterministic and emits nothing', () async {
      for (final history in [
        <DomainEvent>[],
        [..._confirmed, MeetingCanceledEvent(meetingId: _meeting)],
      ]) {
        final first = _decide(_cancel(requestedBy: _stranger), history);
        await expectLater(first, throwsA(isA<RequestMeetingCancellationError>()));
        await expectLater(
          _decide(_cancel(requestedBy: _stranger), history),
          throwsA(isA<RequestMeetingCancellationError>()),
        );
      }
    });

    // @ensures: the decision reads only the meeting stream; another meeting's history does not change it.
    test('another meeting does not affect the decision', () async {
      final other = MeetingSlotReservedEvent(
        meetingId: MeetingId('meeting-2'),
        hostId: _host,
        bookerId: _booker,
        meetingTypeId: MeetingTypeId('meeting-type-1'),
        meetingTitle: MeetingTitle('30-minute consultation'),
        meetingLocation: MeetingLocation('Video call'),
        slotStart: SlotStart(_slotStart),
        slotEnd: SlotEnd(_slotEnd),
        participants: Participants.empty(),
      );
      final emitted = await _decide(_cancel(), [other, ..._confirmed]);
      expect(emitted.single, isA<MeetingCancellationRequestedEvent>());
    });
  });
}
