-- schema_migrations is created by the migrator

CREATE TABLE IF NOT EXISTS markets (
  slug text PRIMARY KEY,
  ticker text NOT NULL,
  name text NOT NULL,
  venue text NOT NULL DEFAULT 'pumpfun',
  mint text NOT NULL UNIQUE,
  pair_address text,
  image_url text NOT NULL,
  price_usd numeric NOT NULL DEFAULT 0,
  change_1h numeric NOT NULL DEFAULT 0,
  mcap_usd numeric NOT NULL DEFAULT 0,
  pool_depth_usd numeric NOT NULL DEFAULT 0,
  age_hours numeric NOT NULL DEFAULT 0,
  volume_24h_usd numeric NOT NULL DEFAULT 0,
  short_oi_usd numeric NOT NULL DEFAULT 0,
  long_oi_usd numeric NOT NULL DEFAULT 0,
  coming_soon boolean NOT NULL DEFAULT false,
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS wallets (
  address text PRIMARY KEY,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS positions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_address text NOT NULL REFERENCES wallets(address) ON DELETE CASCADE,
  slug text NOT NULL REFERENCES markets(slug),
  ticker text NOT NULL,
  direction text NOT NULL CHECK (direction IN ('long', 'short')),
  size_sol numeric NOT NULL,
  premium_sol numeric NOT NULL,
  posted_sol numeric NOT NULL,
  term text NOT NULL,
  leverage integer NOT NULL,
  open_price numeric NOT NULL,
  open_time timestamptz NOT NULL DEFAULT now(),
  expiry_time timestamptz NOT NULL,
  liquidation_price numeric,
  status text NOT NULL DEFAULT 'open',
  settle_change_pct numeric,
  pnl_sol numeric,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS positions_wallet_idx ON positions (wallet_address, created_at DESC);
CREATE INDEX IF NOT EXISTS positions_status_idx ON positions (status);

CREATE TABLE IF NOT EXISTS platform (
  id integer PRIMARY KEY CHECK (id = 1),
  public_key text NOT NULL,
  updated_at timestamptz NOT NULL DEFAULT now()
);
