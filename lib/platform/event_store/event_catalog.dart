import '../../bounded_contexts/event_contract.dart';

/// All event contracts of the application, looked up by event, type name, or Dart type.
final class EventCatalog {
  EventCatalog(List<EventContract<DomainEvent>> contracts) {
    for (final contract in contracts) {
      for (final MapEntry(key: name, value: type) in contract.types.entries) {
        if (_byName.containsKey(name)) throw ArgumentError('Duplicate event type name: $name');
        _byName[name] = contract;
        _names[type] = name;
      }
      _contracts.add(contract);
    }
  }

  final List<EventContract<DomainEvent>> _contracts = [];
  final Map<String, EventContract<DomainEvent>> _byName = {};
  final Map<Type, String> _names = {};

  EventContract<DomainEvent> _contractOf(DomainEvent event) {
    for (final contract in _contracts) {
      if (contract.owns(event)) return contract;
    }
    throw ArgumentError('No event contract owns ${event.runtimeType}');
  }

  String typeNameOf(DomainEvent event) => _contractOf(event).typeNameOf(event);

  /// The stable type name of the Dart event type [type].
  String typeNameFor(Type type) => _names[type] ?? (throw ArgumentError('Unknown event type: $type'));

  EventStream streamOf(DomainEvent event) => _contractOf(event).streamOf(event);

  List<EventTag> tagsOf(DomainEvent event) => _contractOf(event).tagsOf(event);

  JsonMap encode(DomainEvent event) => _contractOf(event).encode(event);

  DomainEvent decode(String typeName, JsonMap json) {
    final contract = _byName[typeName] ?? (throw ArgumentError('Unknown event type name: $typeName'));
    return contract.decode(typeName, json);
  }
}
