# Slice guide

How to add one slice of `docs/internal-meeting-scheduler.em.hcl` to this application. A slice is one folder in
`lib/slices/`. It plugs into the application through one `module.dart` and one line in
`lib/composition/slice_registry.dart`. Nothing else in `lib/` changes when you add a slice.

Read these first, in this order:

1. The block of your workflow in the HCL model, plus every event, field type, and lifecycle rule that it refers to.
2. The slice skill for its kind: `.agents/skills/map-state-change-hcl-to-code/`,
   `.agents/skills/map-state-view-hcl-to-code/`, or `.agents/skills/map-automation-hcl-to-code/` (`SKILL.md` and
   `references/`). Also `.agents/skills/map-event-model-hcl-to-code/references/TEST-RULES.md`.
3. This guide. **Where this guide and a skill differ, this guide wins**: it describes the framework that exists in
   this repository (persistence, routing, UI, and subscriptions).

## 1. What already exists

| Folder | Content | You may change it |
| ------ | ------- | ----------------- |
| `lib/bounded_contexts/<context>/` | Events, value objects, lifecycles, tags, codecs (import `api.dart`) | No |
| `lib/platform/` | Event store, streaming, view store, auth, mail, clock, calendar integration | No |
| `lib/composition/` | `VerticalSlice`, `SliceRegistrar`, `AppServices`, `Application` | Only `slice_registry.dart` |
| `lib/ui/` | `paths.dart` (URL of every screen, all under `/app`), `kit.dart` (UI blocks), `format.dart`, `LocalTime` | No |
| `test/support/` | `TestApp`, `alice`, `bob`, `sample<Context>Events()` | Add helpers only if 2+ slices need them |

If you believe the framework itself is wrong, stop and report it. Do not work around it in the slice.

### The event store (fstore-sql on Postgres)

- Every event is stored in a fstore-sql stream: the aggregate (`meeting`, `meeting_type`, ...) and its identity.
  External events (`corporate_sso`, `corporate_calendar`) use their correlation key as the stream id.
- Every event carries **tags**: its id fields (`hostId`, `meetingId`, `scheduleId`, `meetingTypeId`, `bookerId`,
  `employeeId`), its correlation and deduplication keys (`schedulerMeetingRef`, `schedulerUserRef`, `ssoSubject`,
  `providerEventRef`), and the **stream tags**: the tags of the first event of its stream. Thus every meeting event
  is found by the `hostId`, `bookerId`, and `meetingTypeId` of its `meeting_slot_reserved`, every schedule event by
  the `hostId` of its `availability_schedule_created`, and every meeting-type event by the `hostId` (and the first
  `scheduleId`) of its `meeting_type_created`. A stream tag is the value at the start of the stream. Use it only
  for a relation that never changes (the host of a meeting). The current `scheduleId` of a meeting type comes from
  its latest `meeting_type_created` or `meeting_type_edited` event.
- A query is `(tag: 'hostId', value: id, eventTypes: [A, B])`: events of those types with that tag value.
- Identity mapping across contexts: the signed-in user id = `employee_id` = `host_id` = `booker_id` =
  `requested_by`. `sso_subject` = the employee id. `scheduler_user_ref` = the host id.
  `scheduler_meeting_ref` = the meeting id. Convert with the value-object constructors, for example
  `HostId(event.schedulerUserRef.value)`.

### `AppServices` (what a module receives)

`eventStore`, `viewStore` (documents of materialized views), `clock` (`clock.now()`, always use it for "now"),
`ids` (`ids.newId()` for a field with `generated = true` that is a new identity), `mailer`
(`mailer.send(EmailMessage(...))`), and `absoluteUrl(path)`.

## 2. Slice layout and naming

```text
lib/slices/<slice>/            <slice> = workflow label (state_change, automation) or read-model label (state_view)
  module.dart                  const <Pascal>Slice implements VerticalSlice
  ...                          files of the slice skill (command, state, errors, decider, view, saga, ...)
  ui/<screen>_page.dart        one page component per UI screen of the workflow
test/slices/<slice>/           tests that mirror the files
```

- Import bounded contexts with relative paths: `../../bounded_contexts/meetings/api.dart`.
- Import framework code with relative paths too (`../../platform/...`, `../../composition/...`, `../../ui/...`).
- **Never import another slice.** Link to another slice's screen with the functions of `lib/ui/paths.dart`.
- Register in `lib/composition/slice_registry.dart`: add the import and the const instance, in board order.
- All errors of a slice form one sealed class that `implements Exception` and has a `message`. The message is the
  text of the model (`invalid_transition.reason` or a scenario's `then { error = ... }`), written exactly.

## 3. State change slice

Flow: screen → command → events. Files: `command.dart`, `state.dart`, `errors.dart`, `decider.dart`,
`repository.dart`, `aggregate.dart`, `service.dart`, `dto.dart`, `handler.dart`, `ui/`, `module.dart`.

`command.dart`, `state.dart`, `errors.dart`, and `decider.dart` follow the skill exactly (value equality,
lifecycle enum in the state, one error class per invalid transition or scenario error).

The repository names the queries of the decision. Read **every** event that the decision needs, also those of
`aggregate_dependencies`. The append fails and the command is retried when another writer appends an event that
matches one of these queries in the meantime. This is how "the no-overlap check is serialized per host" works:
query the host's meeting events by `hostId`.

```dart
// repository.dart
import '../../bounded_contexts/host_setup/api.dart';
import '../../platform/event_store/consistent_event_repository.dart';
import '../../platform/event_store/event_store.dart';
import 'command.dart';

final class StartCalendarConnectionEventRepository
    extends ConsistentEventRepository<StartCalendarConnectionCommand, HostSetupEvent> {
  StartCalendarConnectionEventRepository(super.store);

  @override
  List<EventQuery> queriesFor(StartCalendarConnectionCommand command) => [
    (
      tag: 'hostId',
      value: command.hostId.value,
      eventTypes: [CalendarConnectionStartedEvent, CalendarConnectedEvent, CalendarConnectionFailedEvent],
    ),
  ];
}
```

If the decider reads events of several bounded contexts, its event type is `DomainEvent` (from any `api.dart`)
and `evolve` pattern-matches the concrete events. The decider still emits only the events of `command.to`.

```dart
// aggregate.dart
typedef StartCalendarConnectionAggregate = EventSourcingAggregate<
  StartCalendarConnectionCommand, StartCalendarConnectionState, HostSetupEvent, NoMetadata, NoMetadata>;

StartCalendarConnectionAggregate buildStartCalendarConnectionAggregate({
  required StartCalendarConnectionEventRepository repository,
}) => createEventSourcingAggregate(decider: startCalendarConnectionDecider, eventRepository: repository);
```

```dart
// service.dart: one repository per command; handleCommand retries a lost race.
final class StartCalendarConnectionService {
  StartCalendarConnectionService({required EventStore eventStore}) : _eventStore = eventStore;

  final EventStore _eventStore;

  Future<List<HostSetupEvent>> handle(StartCalendarConnectionCommand command) => handleCommand(
    () => buildStartCalendarConnectionAggregate(repository: StartCalendarConnectionEventRepository(_eventStore)),
    command,
  );
}
```

`dto.dart` turns the form into the command. Fields with `generated = true` come from the context, not the form:
the viewer (`request.viewer.employeeId` for `host_id`, `booker_id`, `requested_by`), `services.ids.newId()` for a
new identity, or a read of the event store (for example the title of the meeting type). Invalid input throws
`FormInputError(message)`; the framework redirects back and shows the message.

```dart
// handler.dart
Future<Response> startCalendarConnectionHandler(StartCalendarConnectionService service, FormRequest request) async {
  try {
    await service.handle(StartCalendarConnectionCommand(hostId: HostId(request.viewer.employeeId)));
    return noticeRedirect(calendarRoute, 'Connecting your calendar.');
  } on StartCalendarConnectionError catch (error) {
    return errorRedirect(calendarRoute, error.message);
  }
}
```

`Response` comes from `package:shelf/shelf.dart`. `FormRequest`, `noticeRedirect`, `errorRedirect`, `seeOther`,
and `FormInputError` come from `../../platform/web/http.dart`. Paths come from `../../ui/paths.dart`.

```dart
// module.dart
final class StartCalendarConnectionSlice implements VerticalSlice {
  const StartCalendarConnectionSlice();

  @override
  String get name => 'start_calendar_connection';

  @override
  void register(SliceRegistrar registrar, AppServices services) {
    final service = StartCalendarConnectionService(eventStore: services.eventStore);
    registrar.form(connectCalendarAction, (request) => startCalendarConnectionHandler(service, request));
  }
}
```

A screen whose only control is a button lives on the page of another slice (for example "Connect calendar" on
the calendar page, "Disable" on the meeting types page). Then this slice registers only the form route of
`paths.dart`, and the page slice renders a `PostButton(action: ..., label: ...)` to that path. When a screen has
input fields, this slice registers the page too, with a `PostForm`.

## 4. State view slice (materialized)

Flow: events → read model → screen. The read model is a materialized view: a subscription folds each event into a
JSON document in the view store, and the page reads documents. Files: `state.dart`, `view.dart`,
`repository.dart`, `service.dart`, `dto.dart` (optional), `ui/`, `module.dart`.

- `view.dart`: a pure `View<S?, E>` over domain events (`E` is a context event type or `DomainEvent`). `null` means
  "no document"; returning `null` deletes the document.
- `state.dart`: the state with value equality, `toJson()`, and `fromJson()`. The state holds its own key (for
  example `hostId`). For a list read model, either one document per owner holding the list, or one document per
  item; choose the key that every event of `readmodel.from` can produce.
- `repository.dart`:

```dart
final class CalendarConnectionStatusRepository extends DocumentViewStateRepository<CalendarConnectionStatus> {
  CalendarConnectionStatusRepository(super.store);

  @override
  String get viewName => 'calendar_connection_status';

  /// Every event of readmodel.from must give a key; return null only for an event that changes no document.
  @override
  String? keyOf(StoredEvent event) => event.tagValue('hostId');

  @override
  String keyOfState(CalendarConnectionStatus state) => state.hostId;

  @override
  JsonMap encodeState(CalendarConnectionStatus state) => state.toJson();

  @override
  CalendarConnectionStatus decodeState(JsonMap json) => CalendarConnectionStatus.fromJson(json);
}
```

- `module.dart`:

```dart
@override
void register(SliceRegistrar registrar, AppServices services) {
  final repository = CalendarConnectionStatusRepository(services.viewStore);
  registrar
    ..subscribe(materializedViewSubscription(
      view: calendarConnectionStatusView,
      repository: repository,
      eventTypes: {CalendarConnectionStartedEvent, CalendarConnectedEvent, CalendarConnectionFailedEvent},
    ))
    ..nav(const NavItem(label: 'Calendar', path: calendarRoute, order: 10))
    ..page(calendarRoute, title: 'Calendar connection', builder: (request) => CalendarConnectionPage(
      repository: repository,
      hostId: request.viewer.employeeId,
    ));
}
```

`eventTypes` is exactly `readmodel.from`. Use `repository.load(key)` and `repository.findWhere({...})` to read.
A read model can depend on "now" (for example available slots): store the inputs in the document, and compute
the time-dependent part when the page renders, with `services.clock.now()`, in a pure function that the tests
call with fixed instants.

The slot calculation of the model already exists in `lib/bounded_contexts/host_setup/availability.dart`
(exported by `host_setup/api.dart`): `availableSlots(...)` lists the bookable slots and `checkSlot(...)`
revalidates one chosen slot (`SlotCheck.held`, `.unverified`, `.busy`, `.outsideRules`, `.available`). Fold the
events into `AvailabilityRules`, busy ranges, and held ranges, then call these functions; never reimplement them.

Views are eventually consistent: a page that a form redirects to can render before the subscription has run.
Tell the person what is happening ("Your booking is being confirmed") instead of failing on a missing document.

## 5. Pages (Jaspr, server-rendered)

- A page is a Jaspr component. To load data, extend `AsyncStatelessComponent` (`import 'package:jaspr/server.dart'`)
  and implement `Future<Component> build(BuildContext context)`. Pages are server-only.
- Use `package:jaspr/dom.dart` elements and the blocks of `lib/ui/kit.dart`: `Panel`, `PostForm`, `PostButton`,
  `LinkButton`, `Field` + `textInput` / `textArea` / `selectInput`, `DataTable`, `Badge`, `EmptyState`, `Facts`,
  and `LocalTime(iso: instant.toUtc().toIso8601String())` for every instant a person reads.
- Text: `.text('...')`. Children lists go last. No inline styles; the classes of `web/styles.css` are enough.
- Read `request.param('name')` for path parameters and `request.query[...]` for query parameters.
- Every route of a slice starts with `/app/`. Use the constants of `paths.dart`. `SliceRegistrar` refuses any other
  path, because the sign-in check applies only under `/app`. The path `/` is the public landing page.
- Only participants may manage a meeting (`actor.meeting_participant`): check the viewer against the read model
  and show an error (or redirect with `errorRedirect`) for anyone else.

## 6. Automation slice

Flow: events → read model or processor → command → events. Files: one subfolder per command
(`<command>/command.dart`, `state.dart`, `errors.dart`, `decider.dart`, `repository.dart`, `aggregate.dart`,
`service.dart`), one subfolder per read model (`<readmodel>/state.dart`, `view.dart`, and `repository.dart` when it
is materialized), plus `saga.dart`, `publisher.dart`, `handler.dart`, `module.dart`.

The handler is an `EventSubscription`. It is delivered at least once, so it must be idempotent: the command's
lifecycle rules reject a repeated command, and the handler **catches the command's sealed error and ignores it**
(a rejection is a valid outcome, not a failure). Any other exception makes the event come back later.

Three shapes cover the model:

1. **Translation or reaction to one event.** The saga maps the event (plus processor history, if any) to commands.

```dart
registrar.subscribe(EventSubscription(
  name: 'automation:record_calendar_connected',
  eventTypes: {CalendarAccessGrantedEvent},
  handle: (stored) => recordCalendarConnectedHandler(sagaManager, stored),
));
```

2. **To-do list.** The read model of the automation is a materialized `View` keyed by the work item (usually
   `meetingId`). The handler folds the event into the document with
   `createMaterializedView(view: todoView.mapLeftOnEvent<StoredEvent>((s) => s.event as E), viewStateRepository: repository).handle(stored)`,
   and passes the new state (the item) to the saga. Completion events of the list delete or close the item.

3. **Time-driven worker** (`complete_finished_meeting`). A materialized to-do list (as in 2), plus a
   `ScheduledJob` (`registrar.schedule(...)`) that reads the open items with `repository.findWhere(...)` and sends
   the commands whose time has come (`services.clock.now()`).

`publisher.dart` implements fmodel's `ActionPublisher<C, NoMetadata, NoMetadata>` (`createActionPublisher`): it
sends each command to the service of its subfolder and catches that command's sealed error. A processor that
sends an email (notices) calls `services.mailer.send(...)` before it sends the command that records the notice;
both participants (`participants`) get the email.

Subscription names: `automation:<slice>` for the handler, `view:<viewName>` for a materialized read model
(`materializedViewSubscription` names it). A name must never change once used (it is an fstore-sql view).

## 7. Tests

Write tests with `package:test` under `test/slices/<slice>/`, following the skill's TESTS.md and TEST-RULES.md:

- Decider: one test per scenario (`given` events → `when` command → `then` events or the exact error message),
  grouped by `case`. Use `decider.decide(command, state)` and fold `given` with `decider.evolve`.
- View: one test per view scenario (`given` events → expected state; `empty_history` → initial state).
- Saga / processor: one test per action scenario, including `expect_no_dispatch`.
- Property laws (`// @requires` / `// @ensures`) as the skill describes.
- Wiring: at least one test through `TestApp` (`test/support/test_app.dart`): post the form or append the given
  events, `await t.drain()`, then check the events in `t.events.all`, the redirect (`response.notice`,
  `response.error`, `response.redirectPath`), or the rendered page (`(await t.get(path, as: alice)).body`).

```dart
late TestApp t;
setUp(() async {
  t = TestApp(slices: const [StartCalendarConnectionSlice()]);
  await t.start();
});

test('connect calendar posts start_calendar_connection', () async {
  final response = await t.post(connectCalendarAction, {}, as: alice);
  expect(response.notice, isNotNull);
  expect(t.events.all.map((e) => e.event), [CalendarConnectionStartedEvent(hostId: HostId(alice.employeeId))]);
});
```

`TestApp(now: ...)` fixes the clock (`t.clock`), `t.mailer.sent` holds the sent emails, `t.calendar` is the mock
calendar, and `t.runJobs()` runs every scheduled job once. Pass only your slice (and the slices whose events your
test needs) to `TestApp(slices: [...])`, or use `t.given([...events])`.

## 8. Done means

1. `make gate` passes (format, analyze with infos as errors, unit tests, database tests, model validation, and the
   Jaspr build). Run it from the repository root. Supabase must be running (`make db-up` starts it).
2. The slice is in `lib/composition/slice_registry.dart`.
3. One commit with only the slice's files, its tests, and the registry line:
   `git add lib/slices/<slice> test/slices/<slice> lib/composition/slice_registry.dart` (plus generated
   `lib/main.*.options.dart` if `jaspr build` changed them), message `feat(slices): Add <slice> slice`.
