CREATE TABLE IF NOT EXISTS error_events (
  id bigserial PRIMARY KEY,
  source text NOT NULL CHECK (source IN ('frontend', 'server', 'database')),
  message text NOT NULL,
  stack text,
  path text,
  detail jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS error_events_created_idx ON error_events (created_at DESC);
