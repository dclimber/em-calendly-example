import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../ui/paths.dart';
import 'event_model.dart';
import 'event_model.g.dart';

const _repository = 'https://github.com/dclimber/em-calendly-example';
const _modelFile = 'docs/internal-meeting-scheduler.em.hcl';

/// The chapter that is open when the page loads.
const _featuredChapter = 'book_a_meeting';

/// The booking rules that the page shows as given/when/then examples, from `reserve_meeting_slot`.
const _featuredSlice = 'reserve_meeting_slot';
const _featuredScenarios = [
  'concurrent_booking_loses',
  'slot_that_became_busy_is_refused',
  'host_cannot_book_their_own_link',
];

/// The public start page at `/`: what the app does, and the event model that the code follows.
class LandingPage extends StatelessComponent {
  const LandingPage({this.model = eventModel, super.key});

  final EventModel model;

  @override
  Component build(BuildContext context) {
    return div(classes: 'landing', [
      header(classes: 'topbar', [
        a(href: landingRoute, classes: 'brand', [.text('Meeting Scheduler')]),
        nav([
          a(href: '#how-it-works', [.text('How it works')]),
          a(href: '#model', [.text('Event model')]),
          a(href: '#diagram', [.text('Diagram')]),
          a(href: _repository, [.text('Source')]),
        ]),
        a(href: homeRoute, classes: 'button primary small', [.text('Open the app')]),
      ]),
      main_([
        _hero(),
        _facts(),
        _howItWorks(),
        _model(),
        _scenarios(),
        _diagram(),
      ]),
      footer(classes: 'landing-footer', [
        p([
          .text('Built with '),
          a(href: 'https://pub.dev/packages/fmodel', [.text('fmodel-dart')]),
          .text(', '),
          a(href: 'https://github.com/fraktalio/fstore-sql', [.text('fstore-sql')]),
          .text(', '),
          a(href: 'https://supabase.com', [.text('Supabase')]),
          .text(', and '),
          a(href: 'https://jaspr.site', [.text('Jaspr')]),
          .text('. The source code and the model are on '),
          a(href: _repository, [.text('GitHub')]),
          .text(' under the Apache 2.0 license.'),
        ]),
      ]),
    ]);
  }

  Component _hero() => section(classes: 'hero', [
    p(classes: 'eyebrow', [.text('An open-source example of Event Modeling')]),
    h1([.text('Book time with a colleague in one step.')]),
    p(classes: 'lead', [
      .text(
        'Meeting Scheduler is a booking tool for the employees of one company. A host shares a link. A colleague '
        'opens the link, picks a free time, and the meeting goes into both calendars. Nobody sends emails to find '
        'a time.',
      ),
    ]),
    div(classes: 'actions', [
      a(href: homeRoute, classes: 'button primary', [.text('Open the app')]),
      a(href: '#model', classes: 'button', [.text('See the event model')]),
    ]),
  ]);

  Component _facts() => section(
    classes: 'facts-strip',
    attributes: {'aria-label': 'The model in numbers'},
    [
      _fact(model.chapters.length, 'chapters of the user journey'),
      _fact(model.slices.length, 'workflows, one code folder each'),
      _fact(model.eventCount, 'event types'),
      _fact(model.scenarioCount, 'given/when/then scenarios'),
      _fact(model.contexts.length, 'bounded contexts'),
    ],
  );

  Component _fact(int value, String label) => div(classes: 'fact', [
    strong([.text('$value')]),
    span([.text(label)]),
  ]);

  Component _howItWorks() => section(id: 'how-it-works', classes: 'band', [
    h2([.text('How it works')]),
    ol(classes: 'steps', [
      _step(
        'Connect your calendar',
        'The host signs in with the company account and connects the company calendar. The scheduler reads free '
            'and busy times only.',
      ),
      _step(
        'Set your hours and share a link',
        'The host sets weekly hours, date exceptions, and limits such as minimum notice. Each meeting type gets its '
            'own booking link.',
      ),
      _step(
        'Colleagues book a free time',
        'A colleague opens the link and sees only free times. The scheduler checks the calendar again, creates the '
            'calendar event, and sends an email to both people.',
      ),
    ]),
    p([
      .text(
        'Either person can reschedule or cancel the meeting later. A change made directly in the calendar also '
        'updates the meeting in the scheduler.',
      ),
    ]),
  ]);

  Component _step(String title, String text) => li([
    h3([.text(title)]),
    p([.text(text)]),
  ]);

  Component _model() => section(id: 'model', classes: 'band', [
    h2([.text('Built from an event model')]),
    p([
      .text('The app was written from one file, '),
      a(href: '$_repository/blob/main/$_modelFile', [
        code([.text(_modelFile)]),
      ]),
      .text(
        '. The file is an event model in Event Modeling HCL. An event model describes a system as a timeline of '
        'facts (events), the requests that cause them (commands), and the data that people and processes read '
        '(read models). Each workflow of the model is one folder of code in ',
      ),
      code([.text('lib/slices/')]),
      .text('. The cards below come from the same file.'),
    ]),
    ul(classes: 'legend', [
      for (final (kind, label) in const [
        ('screen', 'Screen: what a person sees'),
        ('processor', 'Processor: an automated step'),
        ('command', 'Command: a request to change something'),
        ('readmodel', 'Read model: data for a screen or a processor'),
        ('event', 'Event: a fact that the system recorded'),
        ('event external', 'External event: a fact from the SSO or the calendar'),
      ])
        li([
          span(classes: 'sticky $kind', []),
          .text(label),
        ]),
    ]),
    for (final chapter in model.chapters) _chapter(chapter),
  ]);

  Component _chapter(ModelChapter chapter) => details(
    open: chapter.name == _featuredChapter,
    classes: 'chapter',
    [
      summary([
        span(classes: 'chapter-title', [.text(chapter.title)]),
        span(classes: 'chapter-count', [.text('${chapter.slices.length} workflows')]),
      ]),
      p(classes: 'chapter-description', [.text(chapter.description)]),
      div(classes: 'slice-row', [for (final slice in chapter.slices) SliceCard(slice)]),
    ],
  );

  Component _scenarios() {
    final slice = model.slice(_featuredSlice);
    final scenarios = [
      for (final name in _featuredScenarios) slice.scenarios.firstWhere((scenario) => scenario.name == name),
    ];
    return section(id: 'rules', classes: 'band', [
      h2([.text('Rules written as examples')]),
      p([
        .text(
          'Each workflow has scenarios in a given, when, then form. Each scenario became a test of its slice. Here '
          'are three rules of the booking step ',
        ),
        code([.text(_featuredSlice)]),
        .text('.'),
      ]),
      div(classes: 'scenarios', [for (final s in scenarios) _scenario(s)]),
    ]);
  }

  Component _scenario(ModelScenario scenario) => article(classes: 'scenario', [
    h3([.text(humanize(scenario.name))]),
    p(classes: 'gwt-label', [.text('Given')]),
    div(classes: 'gwt', [for (final step in scenario.given) _scenarioStep(step)]),
    if (scenario.when case final command?) ...[
      p(classes: 'gwt-label', [.text('When')]),
      div(classes: 'gwt', [_scenarioStep(command)]),
    ],
    p(classes: 'gwt-label', [.text('Then')]),
    div(classes: 'gwt', [for (final step in scenario.then) _scenarioStep(step)]),
  ]);

  Component _scenarioStep(ScenarioStep step) => step.kind == ElementKind.error
      ? p(classes: 'outcome-error', [.text(step.name)])
      : span(classes: 'sticky ${step.kind.name}', [.text(humanize(step.name))]);

  Component _diagram() => section(id: 'diagram', classes: 'band', [
    h2([.text('Explore the full model')]),
    p([
      code([.text('emhcl diagram')]),
      .text(
        ' generates this diagram from the same file. It shows every chapter, workflow, field, and scenario. '
        'Select a chapter in the menu of the diagram to open it.',
      ),
    ]),
    iframe(
      src: eventModelDiagramPath,
      classes: 'diagram',
      attributes: {'title': 'Interactive diagram of the event model', 'loading': 'lazy'},
      [],
    ),
    p([
      a(href: eventModelDiagramPath, attributes: {'target': '_blank'}, [.text('Open the diagram in a new tab')]),
    ]),
  ]);
}

/// One workflow as a small event model board: screens and processors on top, commands and read models in the
/// middle, events at the bottom. Each column is one stage, from left to right.
class SliceCard extends StatelessComponent {
  const SliceCard(this.slice, {super.key});

  final ModelSlice slice;

  static int _lane(ElementKind kind) => switch (kind) {
    ElementKind.screen || ElementKind.processor => 1,
    ElementKind.command || ElementKind.readmodel || ElementKind.error => 2,
    ElementKind.event => 3,
  };

  @override
  Component build(BuildContext context) {
    final cells = <(int, int), List<ModelElement>>{};
    for (final element in slice.elements) {
      (cells[(element.stage, _lane(element.kind))] ??= []).add(element);
    }
    return article(classes: 'slice-card', [
      header([
        a(href: '$_repository/tree/main/lib/slices/${slice.name}', classes: 'slice-name', [
          .text(humanize(slice.name)),
        ]),
        span(classes: 'badge', [.text(slice.kind.label)]),
      ]),
      div(
        classes: 'board',
        attributes: {'style': 'grid-template-columns: repeat(${slice.stages}, minmax(6.5rem, 1fr))'},
        [
          for (final MapEntry(key: (stage, lane), value: elements) in cells.entries)
            div(
              classes: 'cell',
              attributes: {'style': 'grid-column: ${stage + 1}; grid-row: $lane'},
              [
                for (final e in elements)
                  span(
                    classes: 'sticky ${e.kind.name}${e.external ? ' external' : ''}',
                    attributes: {'title': e.context == null ? e.kind.name : '${e.kind.name} of ${e.context}'},
                    [.text(humanize(e.name))],
                  ),
              ],
            ),
        ],
      ),
      p(classes: 'slice-meta', [.text('${slice.scenarios.length} scenarios')]),
    ]);
  }
}

/// `meeting_slot_reserved` → `Meeting slot reserved`.
String humanize(String name) {
  final words = name.replaceAll('_', ' ');
  return words.isEmpty ? words : words[0].toUpperCase() + words.substring(1);
}
