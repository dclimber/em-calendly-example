## Creating a Jira story

## Creating the model in Claude

Using eventmodeling skills, create me a .em.hcl spec and a .html diagram for the product below: [jira-epic](./jira-epic.md)

The model was created, there were hotsports;

> The spec and the emhcl-generated diagram are in the project folder. The model passes validate but not strict, because 13 business questions are still open. The diagram renders over localhost; it was blank in the app's file preview.
Do you want to resolve the 13 open questions now?

Yes, go through them

## Project setup

$ jaspr create em_calendly_example
Select a rendering mode: server: Build a server-rendered site.
Setup routing for different pages of your site? (Y/n) Yes
(Recommended) Use multi-page (server-side) routing? Choosing [no] sets up a single-page application with client-side routing instead. (Y/n) No
Setup Flutter web embedding? (y/N) No
Enable support for using Flutter web plugins in your project? (y/N) No
Use a custom backend package or framework for the server part of your project? (y/N) No
✓ Generated 28 file(s) (0.2s)
✓ [CLI]  (3.9s)

Created project em_calendly_example! In order to get started, run the following commands:
cd em_calendly_example
jaspr serve

jaspr install-skills --agent general

# Prompt
Using fmodel library, https://github.com/fraktalio/fstore-sql, supabase and jaspr turn  /home/darcy/development/active/open_source/em-calendly-example/docs/internal-meeting-scheduler.em.hcl event model into a working code;
  First do a general commit for LICENSE (Apache 2.0), Makefile with `make gate` that runs code checks and tests and other relevant to dart jaspr project things; then create an app "framework", such that every "slice" that is
  then written from an event model, just "plugs" the slice into the app; then delegate to Haiku 5.5 the actual writing of each slice: a Haiku agent shall create one slice, commit it, ensure make gate passes and stop existing;
  then another new, fresh Haiku 5.5 agent implements the next slice; ask me any questions that you need answers for while working.


| 1. Calendar: “Use https://pub.dev/packages/googleapis and have a Mock that works without a GCP project and key, if possible: so if a person supplies the gcp credentials and stuff in the environment -> real integration can…█ |
| 2. SSO: Supabase Auth email+password (Recommended)                                                                                                                                                                            █ |
| 3. Email: SMTP (local Supabase Mailpit) (Recommended)                                                                                                                                                                         █ |
| 4. Read models: Materialized via fstore-sql streaming
