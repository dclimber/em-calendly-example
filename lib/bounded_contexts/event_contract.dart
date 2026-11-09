/// Contracts that every bounded context shares with the event store.
///
/// This file has no infrastructure code. The platform reads events through
/// [EventContract] only.
library;

/// A JSON object, as stored in the `data` column of the event store.
typedef JsonMap = Map<String, Object?>;

/// A name and a value that the event store uses to find events.
typedef EventTag = ({String tag, String value});

/// The fstore-sql stream of an event: `decider` (stream type) and
/// `decider_id` (stream id).
typedef EventStream = ({String type, String id});

/// The supertype of the event hierarchy of every bounded context.
abstract interface class DomainEvent {}

/// Serialization, tagging, and stream identity of the events of one bounded
/// context.
///
/// Function fields stay private: a caller that holds an
/// `EventContract<DomainEvent>` must not read a `Function(E)` field, because
/// Dart checks the covariant type on read.
final class EventContract<E extends DomainEvent> {
  const EventContract({
    required this.context,
    required this.types,
    required String Function(E event) typeName,
    required EventStream Function(E event) stream,
    required List<EventTag> Function(E event) tags,
    required JsonMap Function(E event) encode,
    required E Function(String typeName, JsonMap json) decode,
  }) : _typeName = typeName,
       _stream = stream,
       _tags = tags,
       _encode = encode,
       _decode = decode;

  /// The label of the bounded context, for example `host_setup`.
  final String context;

  /// Each stable event type name, mapped to its Dart type.
  final Map<String, Type> types;

  final String Function(E event) _typeName;
  final EventStream Function(E event) _stream;
  final List<EventTag> Function(E event) _tags;
  final JsonMap Function(E event) _encode;
  final E Function(String typeName, JsonMap json) _decode;

  /// Whether [event] belongs to this bounded context.
  bool owns(Object event) => event is E;

  /// The stable type name of [event].
  String typeNameOf(DomainEvent event) => _typeName(event as E);

  /// The fstore-sql stream that [event] is appended to.
  EventStream streamOf(DomainEvent event) => _stream(event as E);

  /// The tags of [event], without the inherited stream tags.
  List<EventTag> tagsOf(DomainEvent event) => _tags(event as E);

  /// The JSON form of [event].
  JsonMap encode(DomainEvent event) => _encode(event as E);

  /// The event of type [typeName] that [json] encodes.
  E decode(String typeName, JsonMap json) => _decode(typeName, json);
}
