-- Extensions to fstore-sql for this application. fstore-sql keeps one ordered stream per (decider, decider_id).
-- Decisions such as "no overlap across all meetings of a host" read events of many streams. These tables add:
--   * event_tags: tag queries across streams, and append conditions that are serialized per tag.
--   * view_states: the stored state of each materialized view (fmodel ViewStateRepository).
SET search_path TO fstore;

-- Every event has the tags of its own fields, plus the tags of the first event of its stream (stream tags).
CREATE TABLE IF NOT EXISTS event_tags
(
    "offset" BIGINT NOT NULL REFERENCES events ("offset"),
    "tag"    TEXT   NOT NULL,
    "value"  TEXT   NOT NULL,
    PRIMARY KEY ("offset", "tag", "value")
);

CREATE INDEX IF NOT EXISTS event_tags_lookup_index ON event_tags ("tag", "value", "offset");

-- SIDE EFFECT (rule): immutable tags - ignore delete
CREATE OR REPLACE RULE ignore_delete_event_tags AS ON DELETE TO event_tags
    DO INSTEAD NOTHING;

-- SIDE EFFECT (rule): immutable tags - ignore update
CREATE OR REPLACE RULE ignore_update_event_tags AS ON UPDATE TO event_tags
    DO INSTEAD NOTHING;

-- The state of a materialized view, one JSON document per view and key.
CREATE TABLE IF NOT EXISTS view_states
(
    "view"       TEXT                     NOT NULL,
    "key"        TEXT                     NOT NULL,
    "data"       JSONB                    NOT NULL,
    "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    PRIMARY KEY ("view", "key")
);

CREATE INDEX IF NOT EXISTS view_states_data_index ON view_states USING GIN ("data" jsonb_path_ops);

-- fstore-sql functions use unqualified table names. Pin their search_path, so that clients can call them with
-- schema-qualified names and need no session-level SET (a pooled connection may reset its session).
DO
$$
    DECLARE
        f regprocedure;
    BEGIN
        FOR f IN SELECT p.oid::regprocedure
                 FROM pg_proc p
                          JOIN pg_namespace n ON n.oid = p.pronamespace
                 WHERE n.nspname = 'fstore'
            LOOP
                EXECUTE format('ALTER FUNCTION %s SET search_path = fstore, pg_temp', f);
            END LOOP;
    END
$$;
