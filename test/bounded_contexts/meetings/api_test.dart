import 'dart:convert';

import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';
import 'package:em_calendly_example/bounded_contexts/meetings/api.dart';
import 'package:test/test.dart';

import '../../support/samples/meetings_samples.dart';

void main() {
  const contract = meetingsEventContract;
  final samples = sampleMeetingsEvents();

  // @requires samples hold one instance of every meetings event
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
    expect(contract.types.length, 21);
    expect(samples.map((e) => e.runtimeType).toSet().length, 21);
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
      expect(stream.type, isIn(['meeting']));
    }
  });

  // @requires the MeetingSlotReservedEvent sample
  // @ensures id, correlation, and deduplication tags hold the field values
  test('tags of MeetingSlotReservedEvent', () {
    final e = samples.whereType<MeetingSlotReservedEvent>().single;
    expect(contract.tagsOf(e), [
      (tag: 'meetingId', value: e.meetingId.value),
      (tag: 'hostId', value: e.hostId.value),
      (tag: 'bookerId', value: e.bookerId.value),
      (tag: 'meetingTypeId', value: e.meetingTypeId.value),
    ]);
  });

  group('compound list value equality', () {
    // @ensures two Participants with equal items are equal and have equal hash codes
    test('Participants', () {
      final a = Participants([
        Participant(
          employeeId: EmployeeId('alice-employee-id'),
          name: EmployeeName('Alice Example'),
          email: EmployeeEmail('alice@example.com'),
          role: 'host',
        ),
        Participant(
          employeeId: EmployeeId('bob-employee-id'),
          name: EmployeeName('Bob Example'),
          email: EmployeeEmail('bob@example.com'),
          role: 'booker',
        ),
      ]);
      final b = Participants([
        Participant(
          employeeId: EmployeeId('alice-employee-id'),
          name: EmployeeName('Alice Example'),
          email: EmployeeEmail('alice@example.com'),
          role: 'host',
        ),
        Participant(
          employeeId: EmployeeId('bob-employee-id'),
          name: EmployeeName('Bob Example'),
          email: EmployeeEmail('bob@example.com'),
          role: 'booker',
        ),
      ]);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(const Participants.empty())));
      expect(a.items.first, equals(b.items.first));
    });

    // @ensures two AvailableSlots with equal items are equal and have equal hash codes
    test('AvailableSlots', () {
      final a = AvailableSlots([
        AvailableSlot(startAt: DateTime.utc(2026, 11, 16, 9), endAt: DateTime.utc(2026, 11, 16, 9, 30)),
      ]);
      final b = AvailableSlots([
        AvailableSlot(startAt: DateTime.utc(2026, 11, 16, 9), endAt: DateTime.utc(2026, 11, 16, 9, 30)),
      ]);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(const AvailableSlots.empty())));
      expect(a.items.first, equals(b.items.first));
    });
  });
}
