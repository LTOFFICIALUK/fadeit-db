ALTER TABLE positions
  ADD COLUMN IF NOT EXISTS filled_sol numeric NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS fill_kind text NOT NULL DEFAULT 'waiting',
  ADD COLUMN IF NOT EXISTS premium_escrow_sol numeric NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS premium_received_sol numeric NOT NULL DEFAULT 0;

UPDATE positions SET
  filled_sol = size_sol,
  fill_kind = 'organic',
  premium_escrow_sol = 0
WHERE filled_sol = 0;

ALTER TABLE platform
  ADD COLUMN IF NOT EXISTS vault_premium_sol numeric NOT NULL DEFAULT 0;

CREATE TABLE IF NOT EXISTS premium_transfers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text NOT NULL REFERENCES markets(slug),
  short_position_id uuid NOT NULL REFERENCES positions(id) ON DELETE CASCADE,
  long_position_id uuid REFERENCES positions(id) ON DELETE SET NULL,
  to_wallet text NOT NULL,
  fill_sol numeric NOT NULL,
  premium_sol numeric NOT NULL,
  kind text NOT NULL CHECK (kind IN ('organic', 'vault')),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS positions_match_idx
  ON positions (slug, term, direction, status, created_at);
