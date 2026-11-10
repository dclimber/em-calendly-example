# Internal meeting scheduler

A self-service meeting scheduler for employees, built from the Event Modeling HCL model
[`docs/internal-meeting-scheduler.em.hcl`](docs/internal-meeting-scheduler.em.hcl)
([diagram](https://dclimber.github.io/em-calendly-example/), rendered with `emhcl diagram` on every model change) with:

- [fmodel-dart](https://pub.dev/packages/fmodel): deciders, views, and sagas.
- [fstore-sql](https://github.com/fraktalio/fstore-sql): Postgres as event store and event stream.
- [Supabase](https://supabase.com): Postgres, Auth (corporate sign-in), and Mailpit for local email.
- [Jaspr](https://jaspr.site): server-rendered UI.

## Run it

Requirements: Dart 3.10+, the Jaspr CLI (`dart pub global activate jaspr_cli`), the Supabase CLI, Docker (or the
rootless podman socket), and Go (only to build the model validator).

```shell
make db-up    # starts Supabase and applies supabase/migrations
make serve    # http://localhost:8080
```

Create an account on the sign-in page. Emails arrive in Mailpit at http://127.0.0.1:54324.

### Corporate calendar

Without Google credentials, an in-memory mock calendar answers the scheduler, and `/dev/calendar` lets you add
busy time, make calendar operations fail, and move or delete meeting events "in the calendar".

For Google Workspace Calendar, create a service account with domain-wide delegation for the scope
`https://www.googleapis.com/auth/calendar`, and start the server with
`GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json`. The scheduler then acts as each employee by work email.

### Configuration

| Variable | Default |
| -------- | ------- |
| `DATABASE_URL` | `postgresql://postgres:postgres@127.0.0.1:54322/postgres?sslmode=disable` |
| `SUPABASE_URL` | `http://127.0.0.1:54321` |
| `SUPABASE_PUBLISHABLE_KEY` | the default key of the local Supabase stack |
| `SMTP_HOST`, `SMTP_PORT`, `MAIL_FROM` | `127.0.0.1`, `54325`, `scheduler@example.com` |
| `PUBLIC_BASE_URL` | `http://localhost:8080` (booking links) |
| `GOOGLE_APPLICATION_CREDENTIALS` | unset: mock calendar |
| `PORT` | `8080` |

## Develop

`make gate` runs every check: formatting, analysis (with `jaspr_lints`), model validation (`emhcl`), unit tests,
database tests against the local Supabase, and the Jaspr build. `make help` lists all targets.

```text
lib/
  bounded_contexts/   events, value objects, lifecycles, tags, and codecs of each bounded context
  slices/             one folder per workflow (or read model) of the model
  composition/        VerticalSlice, the slice registry, and the application wiring
  platform/           event store, streaming, view store, auth, mail, clock, corporate calendar
  ui/                 screen paths, layout, and UI building blocks
supabase/migrations/  fstore-sql schema, event tags, and view states
```

Each slice plugs in through its `module.dart` and one line in `lib/composition/slice_registry.dart`.
[`docs/slice-guide.md`](docs/slice-guide.md) describes how to add one.

## License

Apache License 2.0, see [LICENSE](LICENSE). The schema in `supabase/migrations/20261109000000_fstore_sql_schema.sql`
comes from fstore-sql, Copyright 2023 Fraktalio D.O.O., Apache License 2.0.
