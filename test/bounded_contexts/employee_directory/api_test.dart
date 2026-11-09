import 'dart:convert';

import 'package:em_calendly_example/bounded_contexts/employee_directory/api.dart';
import 'package:test/test.dart';

import '../../support/samples/employee_directory_samples.dart';

void main() {
  const contract = employeeDirectoryEventContract;
  final samples = sampleEmployeeDirectoryEvents();

  // @requires samples hold one instance of every employee_directory event
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
    expect(contract.types.length, 1);
    expect(samples.map((e) => e.runtimeType).toSet().length, 1);
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
      expect(stream.type, isIn(['employee']));
    }
  });

  // @requires the EmployeeRegisteredEvent sample
  // @ensures id, correlation, and deduplication tags hold the field values
  test('tags of EmployeeRegisteredEvent', () {
    final e = samples.whereType<EmployeeRegisteredEvent>().single;
    expect(contract.tagsOf(e), [(tag: 'employeeId', value: e.employeeId.value)]);
  });
}
