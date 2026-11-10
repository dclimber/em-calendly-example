import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';
import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:em_calendly_example/slices/hosted_meetings/module.dart';
import 'package:em_calendly_example/ui/paths.dart';
import 'package:test/test.dart';

import '../../support/samples/meetings_samples.dart';
import '../../support/test_app.dart';

final _reserved = sampleMeetingsEvents().whereType<MeetingSlotReservedEvent>().single;
final _confirmed = sampleMeetingsEvents().whereType<MeetingConfirmedEvent>().single;
final _canceled = sampleMeetingsEvents().whereType<MeetingCanceledEvent>().single;
final _completed = sampleMeetingsEvents().whereType<MeetingCompletedEvent>().single;
final _rescheduleRequested = sampleMeetingsEvents().whereType<MeetingRescheduleRequestedEvent>().single;
final _rescheduled = sampleMeetingsEvents().whereType<MeetingRescheduledEvent>().single;

const _meetingId = 'f1d91c85-3a90-593b-9d5e-7cb450033766';
final _otherMeetingId = MeetingId('0b6e3f9a-1c2d-5e7f-8a9b-0c1d2e3f4a5b');

/// A second meeting of alice, booked by carol, on 15 November, so it is listed before the sample meeting.
MeetingSlotReservedEvent _otherReserved() => MeetingSlotReservedEvent(
  meetingId: _otherMeetingId,
  hostId: HostId('alice-employee-id'),
  bookerId: BookerId('carol-employee-id'),
  meetingTypeId: MeetingTypeId('e3b5aceb-a393-5517-acf5-fb11936414a5'),
  meetingTitle: MeetingTitle('Quarterly review'),
  meetingLocation: MeetingLocation('Room 4'),
  slotStart: SlotStart(DateTime.utc(2026, 11, 15, 9, 0)),
  slotEnd: SlotEnd(DateTime.utc(2026, 11, 15, 10, 0)),
  participants: Participants([
    Participant(
      employeeId: EmployeeId('alice-employee-id'),
      name: EmployeeName('Alice Example'),
      email: EmployeeEmail('alice@example.com'),
      role: 'host',
    ),
    Participant(
      employeeId: EmployeeId('carol-employee-id'),
      name: EmployeeName('Carol Example'),
      email: EmployeeEmail('carol@example.com'),
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
    t = TestApp(slices: const [HostedMeetingsSlice()]);
    await t.start();
  });

  // @requires no meeting has been booked through alice's links
  // @ensures alice's page says so, with no table
  test('no_bookings_yet: the page shows an empty state', () async {
    final response = await t.get(hostedMeetingsRoute, as: alice);

    expect(response.statusCode, 200);
    expect(response.body, contains('No one has booked a meeting through your links yet.'));
    expect(response.body, isNot(contains('<table')));
  });

  // @requires alice's meeting was reserved by bob and confirmed
  // @ensures alice sees a row with the title, the time, the booker's name, Active, and a link to the details
  test('confirmed_meeting_is_active: alice sees the meeting as a row', () async {
    await t.given([_reserved, _confirmed]);
    await t.drain();
    final response = await t.get(hostedMeetingsRoute, as: alice);

    expect(response.statusCode, 200);
    expect(response.body, contains('30-minute consultation'));
    expect(response.body, contains('Bob Example'));
    expect(response.body, contains('Active'));
    expect(response.body, contains('<time'));
    expect(response.body, contains(meetingDetails(_meetingId)));
  });

  // @requires alice's confirmed meeting was canceled
  // @ensures the row shows Canceled
  test('canceled_meeting_is_marked_canceled: the row shows Canceled', () async {
    await t.given([_reserved, _confirmed, _canceled]);
    await t.drain();
    final response = await t.get(hostedMeetingsRoute, as: alice);

    expect(response.body, contains('Canceled'));
    expect(response.body, isNot(contains('Active')));
  });

  // @requires alice's confirmed meeting has finished
  // @ensures the row shows Completed
  test('finished_meeting_is_marked_completed: the row shows Completed', () async {
    await t.given([_reserved, _confirmed, _completed]);
    await t.drain();
    final response = await t.get(hostedMeetingsRoute, as: alice);

    expect(response.body, contains('Completed'));
    expect(response.body, isNot(contains('Active')));
  });

  // @requires alice's meeting was rescheduled and the reschedule completed
  // @ensures the row shows the requested time, which is the start of the new slot
  test('rescheduled_meeting_shows_the_new_time: the row shows the new slot', () async {
    await t.given([_reserved, _confirmed, _rescheduleRequested, _rescheduled]);
    await t.drain();
    final response = await t.get(hostedMeetingsRoute, as: alice);

    expect(response.body, contains(_rescheduleRequested.newSlotStart.value.toUtc().toIso8601String()));
  });

  // @requires a reserved meeting failed before it was confirmed
  // @ensures alice's page says no one has booked a meeting, since the failed booking is not listed
  test('failed_booking_is_not_listed', () async {
    await t.given([_reserved]);
    await t.drain();
    final response = await t.get(hostedMeetingsRoute, as: alice);

    expect(response.body, isNot(contains('30-minute consultation')));
    expect(response.body, contains('No one has booked a meeting through your links yet.'));
  });

  // @requires two confirmed meetings of alice, the later one reserved first
  // @ensures the rows are sorted by start time, earliest first
  test('rows are sorted by start time', () async {
    await t.given([_reserved, _confirmed, _otherReserved(), _otherConfirmed()]);
    await t.drain();
    final body = (await t.get(hostedMeetingsRoute, as: alice)).body;

    expect(body.indexOf('Quarterly review'), lessThan(body.indexOf('30-minute consultation')));
  });

  // @requires another employee, bob, is the booker of alice's meeting and has no meetings of his own as host
  // @ensures bob does not see alice's meeting
  test('another employee does not see the meetings', () async {
    await t.given([_reserved, _confirmed]);
    await t.drain();
    final response = await t.get(hostedMeetingsRoute, as: bob);

    expect(response.body, contains('No one has booked a meeting through your links yet.'));
    expect(response.body, isNot(contains('30-minute consultation')));
  });

  // @requires another meeting of alice is canceled, while the sample meeting stays confirmed
  // @ensures the sample meeting is still Active, and only the other meeting is Canceled
  test('events of another meeting change nothing', () async {
    await t.given([_reserved, _confirmed, _otherReserved(), _otherConfirmed(), _otherCanceled()]);
    await t.drain();
    final body = (await t.get(hostedMeetingsRoute, as: alice)).body;

    expect(_count(body, 'Active'), 1);
    expect(_count(body, 'Canceled'), 1);
    expect(body.indexOf('Canceled'), greaterThan(body.indexOf('Quarterly review')));
    expect(body.indexOf('Canceled'), lessThan(body.indexOf('30-minute consultation')));
  });
}
