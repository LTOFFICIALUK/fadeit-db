ALTER TABLE markets
  ADD COLUMN IF NOT EXISTS demo_short_oi_usd numeric NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS demo_long_oi_usd numeric NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS vault_token_balance numeric NOT NULL DEFAULT 0;

UPDATE markets
SET
  demo_short_oi_usd = short_oi_usd,
  demo_long_oi_usd = long_oi_usd
WHERE demo_short_oi_usd = 0 AND demo_long_oi_usd = 0;

ALTER TABLE positions
  ADD COLUMN IF NOT EXISTS payout_kind text,
  ADD COLUMN IF NOT EXISTS payout_tokens numeric,
  ADD COLUMN IF NOT EXISTS settle_price numeric,
  ADD COLUMN IF NOT EXISTS rake_sol numeric;

CREATE INDEX IF NOT EXISTS positions_market_open_idx
  ON positions (slug, status, expiry_time);

CREATE TABLE IF NOT EXISTS amm_buys (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text NOT NULL REFERENCES markets(slug),
  source_position_id uuid REFERENCES positions(id) ON DELETE SET NULL,
  sol_spent numeric NOT NULL,
  tokens_out numeric NOT NULL,
  rake_sol numeric NOT NULL DEFAULT 0,
  price_before numeric NOT NULL,
  price_after numeric NOT NULL,
  pool_before_usd numeric NOT NULL,
  pool_after_usd numeric NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS amm_buys_slug_idx ON amm_buys (slug, created_at DESC);
