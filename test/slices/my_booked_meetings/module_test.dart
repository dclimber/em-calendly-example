import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';
import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/my_booked_meetings/module.dart';
import 'package:em_calendly_example/ui/paths.dart';
import 'package:test/test.dart';

import '../../support/samples/meetings_samples.dart';
import '../../support/test_app.dart';

final _reserved = sampleMeetingsEvents().whereType<MeetingSlotReservedEvent>().single;
final _confirmed = sampleMeetingsEvents().whereType<MeetingConfirmedEvent>().single;
final _canceled = sampleMeetingsEvents().whereType<MeetingCanceledEvent>().single;
final _rescheduleRequested = sampleMeetingsEvents().whereType<MeetingRescheduleRequestedEvent>().single;
final _rescheduled = sampleMeetingsEvents().whereType<MeetingRescheduledEvent>().single;

const _meetingId = 'f1d91c85-3a90-593b-9d5e-7cb450033766';
final _otherMeetingId = MeetingId('0b6e3f9a-1c2d-5e7f-8a9b-0c1d2e3f4a5b');

/// A second meeting booked by bob with alice, on 15 November, so it is listed before the sample meeting.
MeetingSlotReservedEvent _otherReserved() => MeetingSlotReservedEvent(
  meetingId: _otherMeetingId,
  hostId: HostId('carol-employee-id'),
  bookerId: BookerId('bob-employee-id'),
  meetingTypeId: MeetingTypeId('e3b5aceb-a393-5517-acf5-fb11936414a5'),
  meetingTitle: MeetingTitle('Quarterly review'),
  meetingLocation: MeetingLocation('Room 4'),
  slotStart: SlotStart(DateTime.utc(2026, 11, 15, 9, 0)),
  slotEnd: SlotEnd(DateTime.utc(2026, 11, 15, 10, 0)),
  participants: Participants([
    Participant(
      employeeId: EmployeeId('carol-employee-id'),
      name: EmployeeName('Carol Example'),
      email: EmployeeEmail('carol@example.com'),
      role: 'host',
    ),
    Participant(
      employeeId: EmployeeId('bob-employee-id'),
      name: EmployeeName('Bob Example'),
      email: EmployeeEmail('bob@example.com'),
      role: 'booker',
    ),
  ]),
);

MeetingConfirmedEvent _otherConfirmed() =>
    MeetingConfirmedEvent(meetingId: _otherMeetingId, calendarEventId: CalendarEventId('evt-other'));

MeetingCanceledEvent _otherCanceled() => MeetingCanceledEvent(meetingId: _otherMeetingId);

int _count(String body, String text) => RegExp(RegExp.escape(text)).allMatches(body).length;

void main() {
  late TestApp t;

  setUp(() async {
    t = TestApp(slices: const [MyBookedMeetingsSlice()]);
    await t.start();
  });

  // @requires bob has booked no meeting
  // @ensures bob's page says so, with no table
  test('no_booked_meetings_yet: the page shows an empty state', () async {
    final response = await t.get(bookedMeetingsRoute, as: bob);

    expect(response.statusCode, 200);
    expect(response.body, contains('You have not booked any meetings yet.'));
    expect(response.body, isNot(contains('<table')));
  });

  // @requires bob reserved a meeting with alice and it was confirmed
  // @ensures bob sees a row with the title, the time, the host's name, Active, and a link to the details
  test('booked_meeting_appears: bob sees the meeting as a row', () async {
    await t.given([_reserved, _confirmed]);
    await t.drain();
    final response = await t.get(bookedMeetingsRoute, as: bob);

    expect(response.statusCode, 200);
    expect(response.body, contains('30-minute consultation'));
    expect(response.body, contains('Alice Example'));
    expect(response.body, contains('Active'));
    expect(response.body, contains('<time'));
    expect(response.body, contains(meetingDetails(_meetingId)));
  });

  // @requires bob's confirmed meeting was canceled
  // @ensures the row shows Canceled
  test('canceled_meeting_is_marked_canceled: the row shows Canceled', () async {
    await t.given([_reserved, _confirmed, _canceled]);
    await t.drain();
    final response = await t.get(bookedMeetingsRoute, as: bob);

    expect(response.body, contains('Canceled'));
    expect(response.body, isNot(contains('Active')));
  });

  // @requires bob's meeting was rescheduled and the reschedule completed
  // @ensures the row shows the start of the new slot
  test('rescheduled_meeting_shows_the_new_time: the row shows the new slot', () async {
    await t.given([_reserved, _confirmed, _rescheduleRequested, _rescheduled]);
    await t.drain();
    final response = await t.get(bookedMeetingsRoute, as: bob);

    expect(response.body, contains(_rescheduleRequested.newSlotStart.value.toUtc().toIso8601String()));
  });

  // @requires a reserved meeting failed before it was confirmed
  // @ensures bob's page says he has booked no meeting, since the failed booking is not listed
  test('failed_booking_is_not_listed', () async {
    await t.given([_reserved]);
    await t.drain();
    final response = await t.get(bookedMeetingsRoute, as: bob);

    expect(response.body, isNot(contains('30-minute consultation')));
    expect(response.body, contains('You have not booked any meetings yet.'));
  });

  // @requires two confirmed meetings of bob, the later one reserved first
  // @ensures the rows are sorted by start time, earliest first
  test('rows are sorted by start time', () async {
    await t.given([_reserved, _confirmed, _otherReserved(), _otherConfirmed()]);
    await t.drain();
    final body = (await t.get(bookedMeetingsRoute, as: bob)).body;

    expect(body.indexOf('Quarterly review'), lessThan(body.indexOf('30-minute consultation')));
  });

  // @requires alice is the host of bob's meeting and has booked nothing herself
  // @ensures alice does not see bob's meeting on her booked-meetings page
  test('the host does not see the meeting on the booked page', () async {
    await t.given([_reserved, _confirmed]);
    await t.drain();
    final response = await t.get(bookedMeetingsRoute, as: alice);

    expect(response.body, contains('You have not booked any meetings yet.'));
    expect(response.body, isNot(contains('30-minute consultation')));
  });

  // @requires another meeting of bob is canceled, while the sample meeting stays confirmed
  // @ensures the sample meeting is still Active, and only the other meeting is Canceled
  test('events of another meeting change nothing', () async {
    await t.given([_reserved, _confirmed, _otherReserved(), _otherConfirmed(), _otherCanceled()]);
    await t.drain();
    final body = (await t.get(bookedMeetingsRoute, as: bob)).body;

    expect(_count(body, 'Active'), 1);
    expect(_count(body, 'Canceled'), 1);
    expect(body.indexOf('Canceled'), greaterThan(body.indexOf('Quarterly review')));
    expect(body.indexOf('Canceled'), lessThan(body.indexOf('30-minute consultation')));
  });
}
