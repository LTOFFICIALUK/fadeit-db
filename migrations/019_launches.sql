ALTER TABLE markets
  ADD COLUMN IF NOT EXISTS origin text NOT NULL DEFAULT 'listed',
  ADD COLUMN IF NOT EXISTS launch_state text NOT NULL DEFAULT 'live';

CREATE TABLE IF NOT EXISTS launches (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  mint text NOT NULL,
  launcher_wallet text NOT NULL,
  slug text NOT NULL,
  name text NOT NULL,
  ticker text NOT NULL,
  description text NOT NULL,
  x_url text NOT NULL,
  website text,
  image_uri text NOT NULL,
  dev_buy_sol numeric NOT NULL DEFAULT 0,
  pool_wallet text NOT NULL,
  shares_json jsonb NOT NULL,
  memo text NOT NULL,
  status text NOT NULL DEFAULT 'building',
  reject_reason text,
  created_at timestamptz NOT NULL DEFAULT now(),
  verified_at timestamptz
);

ALTER TABLE launches ADD COLUMN IF NOT EXISTS back_pool text;
ALTER TABLE launches ADD COLUMN IF NOT EXISTS creator_wallet text;
ALTER TABLE launches ADD COLUMN IF NOT EXISTS dev_supply_status text NOT NULL DEFAULT 'none';
ALTER TABLE launches ADD COLUMN IF NOT EXISTS received_tokens bigint NOT NULL DEFAULT 0;
ALTER TABLE launches ADD COLUMN IF NOT EXISTS progress_json jsonb;

CREATE UNIQUE INDEX IF NOT EXISTS launches_mint_idx ON launches (mint);
CREATE INDEX IF NOT EXISTS launches_wallet_created_idx ON launches (launcher_wallet, created_at DESC);

CREATE TABLE IF NOT EXISTS creator_fee_claims (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  pool_slug text NOT NULL,
  claimed_lamports bigint NOT NULL,
  keep_lamports bigint NOT NULL,
  burn_lamports bigint NOT NULL,
  status text NOT NULL DEFAULT 'pending_burn',
  created_at timestamptz NOT NULL DEFAULT now(),
  burned_at timestamptz
);

CREATE TABLE IF NOT EXISTS blocked_shorters (
  coin text NOT NULL,
  wallet text NOT NULL,
  reason text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (coin, wallet)
);
