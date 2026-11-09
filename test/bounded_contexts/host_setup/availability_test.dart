import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:test/test.dart';

void main() {
  const thirty = Duration(minutes: 30);
  // The Tuesday before the slots of the model's examples, so that 2027-03-22 is the first Monday.
  final now = DateTime.utc(2027, 3, 16, 8);
  TimeRange r(String start, String end) => (start: DateTime.parse(start), end: DateTime.parse(end));

  // scenario only_slots_that_satisfy_the_rules_appear
  test('weekly hours minus busy time, cut to the duration', () {
    final rules = AvailabilityRules(
      timeZone: 'Europe/Berlin',
      weeklyHours: [const WeeklyHoursEntry(weekday: 'Monday', startTime: '09:00', endTime: '10:30')],
      bookingWindowDays: 8,
    );
    final slots = availableSlots(
      rules: rules,
      duration: thirty,
      now: now,
      busy: [r('2027-03-22T08:30:00Z', '2027-03-22T09:00:00Z')],
    );
    expect(slots, [
      r('2027-03-22T08:00:00Z', '2027-03-22T08:30:00Z'),
      r('2027-03-22T09:00:00Z', '2027-03-22T09:30:00Z'),
    ]);
  });

  // scenario local_hours_hold_across_daylight_saving
  test('local hours hold across a daylight-saving change', () {
    final rules = AvailabilityRules(
      timeZone: 'Europe/Berlin',
      weeklyHours: [const WeeklyHoursEntry(weekday: 'Monday', startTime: '09:00', endTime: '09:30')],
      bookingWindowDays: 15,
    );
    expect(availableSlots(rules: rules, duration: thirty, now: now), [
      r('2027-03-22T08:00:00Z', '2027-03-22T08:30:00Z'),
      r('2027-03-29T07:00:00Z', '2027-03-29T07:30:00Z'),
    ]);
  });

  final monday = AvailabilityRules(
    weeklyHours: [const WeeklyHoursEntry(weekday: 'Monday', startTime: '09:00', endTime: '12:00')],
    bookingWindowDays: 8,
  );

  // @ensures an empty exception makes the whole date unavailable; an exception with hours replaces the weekly hours
  test('date exceptions replace the weekly hours of their date', () {
    final closed = AvailabilityRules(
      weeklyHours: monday.weeklyHours,
      bookingWindowDays: 8,
      dateExceptions: {DateTime.utc(2027, 3, 22): const []},
    );
    expect(availableSlots(rules: closed, duration: thirty, now: now), isEmpty);
    final short = AvailabilityRules(
      weeklyHours: monday.weeklyHours,
      bookingWindowDays: 8,
      dateExceptions: {
        DateTime.utc(2027, 3, 22): [const ExceptionHoursRange(startTime: '10:00', endTime: '10:30')],
      },
    );
    expect(availableSlots(rules: short, duration: thirty, now: now), [
      r('2027-03-22T10:00:00Z', '2027-03-22T10:30:00Z'),
    ]);
  });

  // @ensures held slots and busy time are removed together with the buffers
  test('buffers widen held and busy ranges', () {
    final rules = AvailabilityRules(
      weeklyHours: monday.weeklyHours,
      bookingWindowDays: 8,
      bufferBeforeMinutes: 15,
      bufferAfterMinutes: 15,
    );
    final slots = availableSlots(
      rules: rules,
      duration: thirty,
      now: now,
      held: [r('2027-03-22T10:00:00Z', '2027-03-22T10:30:00Z')],
    );
    expect(slots, [
      r('2027-03-22T09:00:00Z', '2027-03-22T09:30:00Z'),
      r('2027-03-22T10:45:00Z', '2027-03-22T11:15:00Z'),
      r('2027-03-22T11:15:00Z', '2027-03-22T11:45:00Z'),
    ]);
  });

  // @ensures minimum notice and the booking window bound the start of every slot
  test('minimum notice and booking window', () {
    final rules = AvailabilityRules(weeklyHours: monday.weeklyHours, minimumNoticeMinutes: 60, bookingWindowDays: 1);
    final mondayMorning = DateTime.utc(2027, 3, 22, 9, 10);
    expect(
      availableSlots(rules: rules, duration: thirty, now: mondayMorning).first.start,
      DateTime.utc(2027, 3, 22, 10, 30),
    );
    expect(availableSlots(rules: rules, duration: thirty, now: now), isEmpty);
  });

  // scenario failed_connection_offers_no_unverified_slots
  test('a failed calendar connection offers nothing', () {
    expect(availableSlots(rules: monday, duration: thirty, now: now, calendarFailed: true), isEmpty);
  });

  group('checkSlot', () {
    final slot = r('2027-03-22T09:00:00Z', '2027-03-22T09:30:00Z');

    test('accepts a slot inside the rules, also off the grid', () {
      expect(checkSlot(rules: monday, slot: slot, duration: thirty, now: now), SlotCheck.available);
      expect(
        checkSlot(rules: monday, slot: r('2027-03-22T09:10:00Z', '2027-03-22T09:40:00Z'), duration: thirty, now: now),
        SlotCheck.available,
      );
    });

    // @ensures the checks run in the order held, unverified, busy, outside the rules
    test('reports the first failing check', () {
      final all = checkSlot(
        rules: const AvailabilityRules(),
        slot: slot,
        duration: thirty,
        now: now,
        held: [slot],
        busy: [slot],
        calendarFailed: true,
      );
      expect(all, SlotCheck.held);
      expect(
        checkSlot(
          rules: const AvailabilityRules(),
          slot: slot,
          duration: thirty,
          now: now,
          busy: [slot],
          calendarFailed: true,
        ),
        SlotCheck.unverified,
      );
      expect(
        checkSlot(rules: const AvailabilityRules(), slot: slot, duration: thirty, now: now, busy: [slot]),
        SlotCheck.busy,
      );
      expect(
        checkSlot(rules: const AvailabilityRules(), slot: slot, duration: thirty, now: now),
        SlotCheck.outsideRules,
      );
    });

    test('refuses a slot whose length is not the duration', () {
      expect(
        checkSlot(rules: monday, slot: r('2027-03-22T09:00:00Z', '2027-03-22T10:00:00Z'), duration: thirty, now: now),
        SlotCheck.outsideRules,
      );
    });

    // @ensures every slot that availableSlots offers passes checkSlot
    test('every offered slot passes the check', () {
      final rules = AvailabilityRules(
        timeZone: 'Europe/Berlin',
        weeklyHours: [
          for (final d in ['Monday', 'Wednesday', 'Friday'])
            WeeklyHoursEntry(weekday: d, startTime: '08:15', endTime: '16:45'),
        ],
        bufferAfterMinutes: 10,
        minimumNoticeMinutes: 120,
      );
      final held = [r('2027-03-17T09:00:00Z', '2027-03-17T10:00:00Z')];
      final busy = [r('2027-03-19T12:05:00Z', '2027-03-19T12:20:00Z')];
      for (final duration in const [Duration(minutes: 15), thirty, Duration(minutes: 45)]) {
        final slots = availableSlots(rules: rules, duration: duration, now: now, held: held, busy: busy);
        expect(slots, isNotEmpty);
        for (final s in slots) {
          expect(
            checkSlot(rules: rules, slot: s, duration: duration, now: now, held: held, busy: busy),
            SlotCheck.available,
          );
        }
      }
    });
  });
}
