import 'dart:convert';

import 'package:em_calendly_example/bounded_contexts/host_setup/api.dart';
import 'package:test/test.dart';

import '../../support/samples/host_setup_samples.dart';

void main() {
  const contract = hostSetupEventContract;
  final samples = sampleHostSetupEvents();

  // @requires samples hold one instance of every host_setup event
  // @ensures decode(encode(e)) == e
  test('codec round trip', () {
    for (final e in samples) {
      final name = contract.typeNameOf(e);
      expect(contract.decode(name, contract.encode(e)), equals(e), reason: name);
      final json = jsonDecode(jsonEncode(contract.encode(e))) as JsonMap;
      expect(contract.decode(name, json), equals(e), reason: name);
    }
  });

  // @ensures an unknown type name throws ArgumentError
  test('unknown type name', () {
    expect(() => contract.decode('NoSuchEvent', const {}), throwsArgumentError);
  });

  // @ensures every type name maps to its Dart type
  test('type names', () {
    expect(contract.types.length, 15);
    expect(samples.map((e) => e.runtimeType).toSet().length, 15);
    for (final e in samples) {
      expect(contract.types[contract.typeNameOf(e)], e.runtimeType);
      expect(contract.owns(e), isTrue);
    }
  });

  // @ensures every stream has a non-empty id and the aggregate label as type
  test('streams', () {
    for (final e in samples) {
      final stream = contract.streamOf(e);
      expect(stream.id, isNotEmpty);
      expect(stream.type, isIn(['availability_schedule', 'calendar_connection', 'meeting_type']));
    }
  });

  // @requires the MeetingTypeCreatedEvent sample
  // @ensures id, correlation, and deduplication tags hold the field values
  test('tags of MeetingTypeCreatedEvent', () {
    final e = samples.whereType<MeetingTypeCreatedEvent>().single;
    expect(contract.tagsOf(e), [
      (tag: 'meetingTypeId', value: e.meetingTypeId.value),
      (tag: 'hostId', value: e.hostId.value),
      (tag: 'scheduleId', value: e.scheduleId.value),
    ]);
  });

  group('compound list value equality', () {
    // @ensures two BusyIntervals with equal items are equal and have equal hash codes
    test('BusyIntervals', () {
      final a = BusyIntervals([
        BusyInterval(busyFrom: DateTime.utc(2026, 11, 16, 9), busyUntil: DateTime.utc(2026, 11, 16, 10)),
        BusyInterval(busyFrom: DateTime.utc(2026, 11, 16, 13), busyUntil: DateTime.utc(2026, 11, 16, 14)),
      ]);
      final b = BusyIntervals([
        BusyInterval(busyFrom: DateTime.utc(2026, 11, 16, 9), busyUntil: DateTime.utc(2026, 11, 16, 10)),
        BusyInterval(busyFrom: DateTime.utc(2026, 11, 16, 13), busyUntil: DateTime.utc(2026, 11, 16, 14)),
      ]);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(const BusyIntervals.empty())));
      expect(a.items.first, equals(b.items.first));
    });

    // @ensures two WeeklyHours with equal items are equal and have equal hash codes
    test('WeeklyHours', () {
      final a = WeeklyHours([
        WeeklyHoursEntry(weekday: 'monday', startTime: '09:00', endTime: '17:00'),
        WeeklyHoursEntry(weekday: 'friday', startTime: '09:00', endTime: '13:00'),
      ]);
      final b = WeeklyHours([
        WeeklyHoursEntry(weekday: 'monday', startTime: '09:00', endTime: '17:00'),
        WeeklyHoursEntry(weekday: 'friday', startTime: '09:00', endTime: '13:00'),
      ]);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(const WeeklyHours.empty())));
      expect(a.items.first, equals(b.items.first));
    });

    // @ensures two ExceptionHours with equal items are equal and have equal hash codes
    test('ExceptionHours', () {
      final a = ExceptionHours([ExceptionHoursRange(startTime: '10:00', endTime: '12:00')]);
      final b = ExceptionHours([ExceptionHoursRange(startTime: '10:00', endTime: '12:00')]);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(const ExceptionHours.empty())));
      expect(a.items.first, equals(b.items.first));
    });

    // @ensures two DateExceptions with equal items are equal and have equal hash codes
    test('DateExceptions', () {
      final a = DateExceptions([
        DateException(
          exceptionDate: DateTime.utc(2026, 12, 24),
          hours: ExceptionHours([ExceptionHoursRange(startTime: '09:00', endTime: '12:00')]),
        ),
      ]);
      final b = DateExceptions([
        DateException(
          exceptionDate: DateTime.utc(2026, 12, 24),
          hours: ExceptionHours([ExceptionHoursRange(startTime: '09:00', endTime: '12:00')]),
        ),
      ]);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(const DateExceptions.empty())));
      expect(a.items.first, equals(b.items.first));
    });
  });
}
