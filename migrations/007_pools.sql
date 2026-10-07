CREATE TABLE IF NOT EXISTS coin_pools (
  slug text PRIMARY KEY REFERENCES markets(slug),
  seed_lamports bigint NOT NULL DEFAULT 0,
  backer_lamports bigint NOT NULL DEFAULT 0,
  reserved_lamports bigint NOT NULL DEFAULT 0,
  fee_lamports bigint NOT NULL DEFAULT 0
);

INSERT INTO coin_pools (slug)
SELECT slug FROM markets
ON CONFLICT (slug) DO NOTHING;

CREATE TABLE IF NOT EXISTS index_pool (
  id integer PRIMARY KEY CHECK (id = 1),
  buffer_lamports bigint NOT NULL DEFAULT 0,
  depositor_lamports bigint NOT NULL DEFAULT 0,
  reserved_lamports bigint NOT NULL DEFAULT 0,
  fee_lamports bigint NOT NULL DEFAULT 0
);

INSERT INTO index_pool (id) VALUES (1) ON CONFLICT (id) DO NOTHING;

ALTER TABLE positions
  ADD COLUMN IF NOT EXISTS fill_coin_lamports bigint NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS fill_index_lamports bigint NOT NULL DEFAULT 0;

CREATE TABLE IF NOT EXISTS pool_deposits (
  signature text PRIMARY KEY,
  wallet text NOT NULL,
  pool text NOT NULL,
  lamports bigint NOT NULL,
  epoch_ts timestamptz NOT NULL,
  applied boolean NOT NULL DEFAULT false
);

CREATE TABLE IF NOT EXISTS pool_shares (
  wallet text NOT NULL,
  pool text NOT NULL,
  lamports bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (wallet, pool)
);
