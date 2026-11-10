/// A read-only summary of `docs/internal-meeting-scheduler.em.hcl` for the landing page.
///
/// `event_model.g.dart` holds the data. `tool/generate_event_model.dart` writes it from the output of
/// `emhcl diagram`; run `make event-model` after a change to the model.
library;

/// The four kinds of workflow in Event Modeling HCL.
enum SliceKind {
  stateChange('State change'),
  stateView('State view'),
  automation('Automation'),
  translation('Translation');

  const SliceKind(this.label);

  final String label;
}

/// The kinds of element on an event model board.
enum ElementKind { screen, processor, command, readmodel, event, error }

/// One element of a slice. [stage] is its column on the board, from left to right.
final class ModelElement {
  const ModelElement(this.kind, this.name, this.stage, {this.context, this.external = false});

  final ElementKind kind;
  final String name;
  final int stage;

  /// The bounded context of an event.
  final String? context;

  /// True for an event of an external system (corporate SSO, corporate calendar).
  final bool external;
}

/// A reference in a scenario: an event, a command, a read model, or an error text.
final class ScenarioStep {
  const ScenarioStep(this.kind, this.name);

  final ElementKind kind;
  final String name;
}

/// One given/when/then example of a slice.
final class ModelScenario {
  const ModelScenario(this.name, {required this.given, required this.then, this.when});

  final String name;
  final List<ScenarioStep> given;
  final ScenarioStep? when;
  final List<ScenarioStep> then;
}

/// One workflow of the model, which is one vertical slice of the code in `lib/slices/<name>/`.
final class ModelSlice {
  const ModelSlice(
    this.name,
    this.kind, {
    required this.description,
    required this.stages,
    required this.elements,
    required this.scenarios,
  });

  final String name;
  final SliceKind kind;
  final String description;
  final int stages;
  final List<ModelElement> elements;
  final List<ModelScenario> scenarios;
}

/// One chapter of the board: a part of the user journey, with its slices in board order.
final class ModelChapter {
  const ModelChapter(this.name, {required this.title, required this.description, required this.slices});

  final String name;
  final String title;
  final String description;
  final List<ModelSlice> slices;
}

/// A bounded context and the number of event types that it owns.
final class ModelContext {
  const ModelContext(this.name, {required this.events, this.external = false});

  final String name;
  final int events;
  final bool external;
}

final class EventModel {
  const EventModel({required this.chapters, required this.contexts, required this.actors});

  final List<ModelChapter> chapters;
  final List<ModelContext> contexts;
  final List<String> actors;

  Iterable<ModelSlice> get slices => chapters.expand((c) => c.slices);

  /// The slice named [name]. Throws when the model has no such slice.
  ModelSlice slice(String name) => slices.firstWhere((s) => s.name == name);

  int get eventCount => contexts.fold(0, (sum, c) => sum + c.events);

  int get scenarioCount => slices.fold(0, (sum, s) => sum + s.scenarios.length);
}
