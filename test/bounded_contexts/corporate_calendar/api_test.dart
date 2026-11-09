import 'dart:convert';

import 'package:em_calendly_example/bounded_contexts/corporate_calendar/api.dart';
import 'package:test/test.dart';

import '../../support/samples/corporate_calendar_samples.dart';

void main() {
  const contract = corporateCalendarEventContract;
  final samples = sampleCorporateCalendarEvents();

  // @requires samples hold one instance of every corporate_calendar event
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
    expect(contract.types.length, 14);
    expect(samples.map((e) => e.runtimeType).toSet().length, 14);
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
      expect(stream.type, isIn(['corporate_calendar']));
    }
  });

  // @requires the CalendarEventCreatedEvent sample
  // @ensures id, correlation, and deduplication tags hold the field values
  test('tags of CalendarEventCreatedEvent', () {
    final e = samples.whereType<CalendarEventCreatedEvent>().single;
    expect(contract.tagsOf(e), [
      (tag: 'schedulerMeetingRef', value: e.schedulerMeetingRef.value),
      (tag: 'providerEventRef', value: e.providerEventRef),
    ]);
  });

  group('compound list value equality', () {
    // @ensures two FreeBusyBlocks with equal items are equal and have equal hash codes
    test('FreeBusyBlocks', () {
      final a = FreeBusyBlocks([
        FreeBusyBlock(busyFrom: DateTime.utc(2026, 11, 16, 9), busyUntil: DateTime.utc(2026, 11, 16, 10)),
      ]);
      final b = FreeBusyBlocks([
        FreeBusyBlock(busyFrom: DateTime.utc(2026, 11, 16, 9), busyUntil: DateTime.utc(2026, 11, 16, 10)),
      ]);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(const FreeBusyBlocks.empty())));
      expect(a.items.first, equals(b.items.first));
    });
  });
}
