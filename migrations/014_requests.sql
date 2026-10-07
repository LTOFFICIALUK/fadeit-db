CREATE TABLE IF NOT EXISTS requests (
  id bigserial PRIMARY KEY,
  kind text NOT NULL CHECK (kind IN ('token', 'feature')),
  body text NOT NULL,
  wallet text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS requests_created_at_idx ON requests (created_at DESC);
