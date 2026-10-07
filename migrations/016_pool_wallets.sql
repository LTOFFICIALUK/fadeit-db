CREATE TABLE IF NOT EXISTS custody_wallets (
  id bigserial PRIMARY KEY,
  role text NOT NULL,
  pool_slug text REFERENCES markets(slug),
  address text NOT NULL UNIQUE,
  status text NOT NULL DEFAULT 'assigned',
  created_at timestamptz NOT NULL DEFAULT now(),
  funded_at timestamptz,
  CHECK (role IN (
    'coin_pool', 'index_pool', 'buyback', 'treasury', 'incentive', 'fee_payer', 'legacy_vault'
  )),
  CHECK (status IN ('assigned', 'active', 'paused', 'retired')),
  CHECK (
    (role = 'coin_pool' AND pool_slug IS NOT NULL)
    OR (role <> 'coin_pool' AND pool_slug IS NULL)
  )
);

CREATE UNIQUE INDEX IF NOT EXISTS custody_wallets_coin_pool_uidx
  ON custody_wallets (pool_slug)
  WHERE role = 'coin_pool';

CREATE UNIQUE INDEX IF NOT EXISTS custody_wallets_system_role_uidx
  ON custody_wallets (role)
  WHERE pool_slug IS NULL;

ALTER TABLE coin_pools
  ADD COLUMN IF NOT EXISTS custody_wallet_id bigint REFERENCES custody_wallets(id),
  ADD COLUMN IF NOT EXISTS origin text NOT NULL DEFAULT 'listed',
  ADD COLUMN IF NOT EXISTS state text NOT NULL DEFAULT 'live';

ALTER TABLE index_pool
  ADD COLUMN IF NOT EXISTS custody_wallet_id bigint REFERENCES custody_wallets(id);

ALTER TABLE positions
  ADD COLUMN IF NOT EXISTS deposit_wallet text;

ALTER TABLE deposits
  ADD COLUMN IF NOT EXISTS to_wallet text;

ALTER TABLE pool_deposits
  ADD COLUMN IF NOT EXISTS to_wallet text;

ALTER TABLE chain_payouts
  ADD COLUMN IF NOT EXISTS from_wallet text;

ALTER TABLE payout_jobs
  ADD COLUMN IF NOT EXISTS from_wallet text,
  ADD COLUMN IF NOT EXISTS pool text;

ALTER TABLE solvency_checks
  ADD COLUMN IF NOT EXISTS wallet_id bigint REFERENCES custody_wallets(id);

CREATE TABLE IF NOT EXISTS custody_transfers (
  id bigserial PRIMARY KEY,
  from_address text NOT NULL,
  to_address text NOT NULL,
  from_role text,
  to_role text,
  pool_slug text,
  lamports bigint NOT NULL,
  purpose text NOT NULL,
  signature text,
  dry_run boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS custody_transfers_pool_idx
  ON custody_transfers (pool_slug, created_at DESC);

CREATE INDEX IF NOT EXISTS positions_deposit_wallet_idx
  ON positions (deposit_wallet)
  WHERE deposit_wallet IS NOT NULL;
