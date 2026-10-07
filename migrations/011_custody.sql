ALTER TABLE platform ADD COLUMN IF NOT EXISTS paused boolean NOT NULL DEFAULT false;

ALTER TABLE positions
  ADD COLUMN IF NOT EXISTS void_reason text,
  ADD COLUMN IF NOT EXISTS sample_count integer;

ALTER TABLE pool_withdrawals
  ADD COLUMN IF NOT EXISTS cap_lamports bigint NOT NULL DEFAULT 0;

CREATE TABLE IF NOT EXISTS solvency_checks (
  id bigserial PRIMARY KEY,
  checked_at timestamptz NOT NULL DEFAULT now(),
  vault_lamports bigint NOT NULL,
  liabilities_lamports bigint NOT NULL,
  diff_lamports bigint NOT NULL,
  ok boolean NOT NULL,
  breakdown jsonb NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE IF NOT EXISTS payout_alerts (
  id bigserial PRIMARY KEY,
  created_at timestamptz NOT NULL DEFAULT now(),
  kind text NOT NULL,
  reason text NOT NULL,
  detail jsonb NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE IF NOT EXISTS payout_jobs (
  ref text PRIMARY KEY,
  kind text NOT NULL,
  to_wallet text NOT NULL,
  owner_wallet text NOT NULL,
  lamports bigint NOT NULL,
  cap_lamports bigint NOT NULL,
  position_id uuid,
  status text NOT NULL DEFAULT 'queued',
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS house_buybacks (
  id bigserial PRIMARY KEY,
  lamports bigint NOT NULL,
  tokens_burned bigint NOT NULL DEFAULT 0,
  swap_signature text,
  burn_signature text,
  status text NOT NULL DEFAULT 'pending',
  attempted_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS buyback_slots (
  id bigserial PRIMARY KEY,
  run_at timestamptz NOT NULL UNIQUE,
  spent boolean NOT NULL DEFAULT false
);

CREATE TABLE IF NOT EXISTS treasury_books (
  id integer PRIMARY KEY CHECK (id = 1),
  incentive_lamports bigint NOT NULL DEFAULT 0,
  junior_lamports bigint NOT NULL DEFAULT 0,
  treasury_lamports bigint NOT NULL DEFAULT 0,
  observed_lamports bigint NOT NULL DEFAULT 0
);

INSERT INTO treasury_books (id) VALUES (1) ON CONFLICT (id) DO NOTHING;

CREATE TABLE IF NOT EXISTS creator_claims (
  id bigserial PRIMARY KEY,
  lamports bigint NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS seed_orders (
  id bigserial PRIMARY KEY,
  pool text NOT NULL,
  lamports bigint NOT NULL,
  status text NOT NULL DEFAULT 'queued',
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS incentive_streams (
  id bigserial PRIMARY KEY,
  pool text NOT NULL,
  remaining_lamports bigint NOT NULL,
  slice_lamports bigint NOT NULL,
  next_at timestamptz NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS pool_nav_samples (
  pool text NOT NULL,
  share_price double precision NOT NULL,
  recorded_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS pool_nav_samples_idx ON pool_nav_samples (pool, recorded_at DESC);

UPDATE vault_state
SET buyback_lamports = buyback_lamports + COALESCE((SELECT SUM(buyback_lamports) FROM coin_pools), 0)
WHERE id = 1;

UPDATE coin_pools SET buyback_lamports = 0;
