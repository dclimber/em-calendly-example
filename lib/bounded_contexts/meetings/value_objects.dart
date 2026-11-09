/// Value objects of the `meetings` bounded context.
library;

import '../employee_directory/value_objects.dart';

/// The `meeting_id` field type (String, identity).
extension type const MeetingId._(String value) {
  factory MeetingId(String value) {
    if (value.isEmpty) {
      throw ArgumentError.value(value, 'value', 'MeetingId must not be empty');
    }
    return MeetingId._(value);
  }
}

/// The `booker_id` field type (String, identity).
///
/// Example: `bob-employee-id`.
extension type const BookerId._(String value) {
  factory BookerId(String value) {
    if (value.isEmpty) {
      throw ArgumentError.value(value, 'value', 'BookerId must not be empty');
    }
    return BookerId._(value);
  }
}

/// The `slot_start` field type (DateTime).
extension type const SlotStart._(DateTime value) {
  factory SlotStart(DateTime value) => SlotStart._(value);
}

/// The `slot_end` field type (DateTime).
extension type const SlotEnd._(DateTime value) {
  factory SlotEnd(DateTime value) => SlotEnd._(value);
}

/// The `new_slot_start` field type (DateTime).
extension type const NewSlotStart._(DateTime value) {
  factory NewSlotStart(DateTime value) => NewSlotStart._(value);
}

/// The `new_slot_end` field type (DateTime).
extension type const NewSlotEnd._(DateTime value) {
  factory NewSlotEnd(DateTime value) => NewSlotEnd._(value);
}

/// One entry of the `participants` field type.
final class Participant {
  const Participant({required this.employeeId, required this.name, required this.email, required this.role});

  final EmployeeId employeeId;
  final EmployeeName name;
  final EmployeeEmail email;
  final String role;

  @override
  bool operator ==(Object other) =>
      other is Participant &&
      other.employeeId == employeeId &&
      other.name == name &&
      other.email == email &&
      other.role == role;

  @override
  int get hashCode => Object.hash(runtimeType, employeeId, name, email, role);

  @override
  String toString() => 'Participant(employeeId: $employeeId, name: $name, email: $email, role: $role)';
}

/// The `participants` field type: a list of [Participant].
final class Participants {
  Participants(Iterable<Participant> items) : items = List.unmodifiable(items);

  /// An empty list.
  const Participants.empty() : items = const [];

  final List<Participant> items;

  @override
  bool operator ==(Object other) {
    if (other is! Participants || other.items.length != items.length) return false;
    for (var i = 0; i < items.length; i++) {
      if (other.items[i] != items[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(items);

  @override
  String toString() => 'Participants($items)';
}

/// The `requested_by` field type (String).
extension type const RequestedBy._(String value) {
  factory RequestedBy(String value) => RequestedBy._(value);
}

/// The `calendar_event_id` field type (String).
extension type const CalendarEventId._(String value) {
  factory CalendarEventId(String value) => CalendarEventId._(value);
}

/// The `failure_reason` field type (String).
extension type const FailureReason._(String value) {
  factory FailureReason(String value) => FailureReason._(value);
}

/// The `meeting_status` field type (String).
extension type const MeetingStatus._(String value) {
  factory MeetingStatus(String value) => MeetingStatus._(value);
}

/// One entry of the `available_slots` field type.
final class AvailableSlot {
  const AvailableSlot({required this.startAt, required this.endAt});

  final DateTime startAt;
  final DateTime endAt;

  @override
  bool operator ==(Object other) => other is AvailableSlot && other.startAt == startAt && other.endAt == endAt;

  @override
  int get hashCode => Object.hash(runtimeType, startAt, endAt);

  @override
  String toString() => 'AvailableSlot(startAt: $startAt, endAt: $endAt)';
}

/// The `available_slots` field type: a list of [AvailableSlot].
final class AvailableSlots {
  AvailableSlots(Iterable<AvailableSlot> items) : items = List.unmodifiable(items);

  /// An empty list.
  const AvailableSlots.empty() : items = const [];

  final List<AvailableSlot> items;

  @override
  bool operator ==(Object other) {
    if (other is! AvailableSlots || other.items.length != items.length) return false;
    for (var i = 0; i < items.length; i++) {
      if (other.items[i] != items[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(items);

  @override
  String toString() => 'AvailableSlots($items)';
}
