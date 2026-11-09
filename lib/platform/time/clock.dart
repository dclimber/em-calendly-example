import 'package:uuid/uuid.dart';

/// The current time. Slices read time only through this port, so tests can fix it.
abstract interface class Clock {
  /// The current instant, in UTC.
  DateTime now();
}

final class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now().toUtc();
}

/// A clock that tests set and move.
final class FixedClock implements Clock {
  FixedClock(DateTime now) : _now = now.toUtc();

  DateTime _now;

  @override
  DateTime now() => _now;

  void set(DateTime now) => _now = now.toUtc();

  void advance(Duration duration) => _now = _now.add(duration);
}

/// Makes new identities, for example a `meeting_id` with `generated = true` in the model.
abstract interface class IdGenerator {
  String newId();
}

final class UuidGenerator implements IdGenerator {
  const UuidGenerator();

  static const _uuid = Uuid();

  @override
  String newId() => _uuid.v4();
}

/// Returns the given ids in order, then fails. For tests.
final class SequenceIdGenerator implements IdGenerator {
  SequenceIdGenerator(Iterable<String> ids) : _ids = ids.iterator;

  final Iterator<String> _ids;

  @override
  String newId() => _ids.moveNext() ? _ids.current : throw StateError('SequenceIdGenerator ran out of ids');
}
