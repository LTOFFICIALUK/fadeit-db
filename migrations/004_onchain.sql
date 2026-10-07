ALTER TABLE positions
  ADD COLUMN IF NOT EXISTS deposit_signature text,
  ADD COLUMN IF NOT EXISTS size_lamports bigint NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS escrow_lamports bigint NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS filled_lamports bigint NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS payout_signature text;

CREATE UNIQUE INDEX IF NOT EXISTS positions_deposit_sig_idx
  ON positions (deposit_signature)
  WHERE deposit_signature IS NOT NULL AND deposit_signature NOT LIKE 'vault:%';

CREATE TABLE IF NOT EXISTS deposits (
  signature text PRIMARY KEY,
  wallet text NOT NULL,
  lamports bigint NOT NULL,
  memo text NOT NULL,
  position_id uuid,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS chain_payouts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  position_id uuid REFERENCES positions(id) ON DELETE SET NULL,
  kind text NOT NULL,
  to_wallet text NOT NULL,
  lamports bigint NOT NULL,
  signature text,
  status text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (position_id, kind)
);

CREATE TABLE IF NOT EXISTS price_ticks (
  slug text NOT NULL REFERENCES markets(slug),
  price numeric NOT NULL,
  recorded_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS price_ticks_slug_idx ON price_ticks (slug, recorded_at DESC);

UPDATE markets SET demo_short_oi_usd = 0, demo_long_oi_usd = 0;

UPDATE positions
SET status = 'void'
WHERE status = 'open' AND deposit_signature IS NULL;
