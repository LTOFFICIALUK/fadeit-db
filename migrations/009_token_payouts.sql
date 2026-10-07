ALTER TABLE chain_payouts ADD COLUMN IF NOT EXISTS ref text;
UPDATE chain_payouts SET ref = position_id::text || ':' || kind WHERE ref IS NULL AND position_id IS NOT NULL;
UPDATE chain_payouts SET ref = id::text WHERE ref IS NULL;
ALTER TABLE chain_payouts ALTER COLUMN ref SET NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS chain_payouts_ref_idx ON chain_payouts (ref);

ALTER TABLE pool_shares ADD COLUMN IF NOT EXISTS basis_lamports bigint NOT NULL DEFAULT 0;
UPDATE pool_shares SET basis_lamports = lamports WHERE basis_lamports = 0 AND lamports > 0;

ALTER TABLE pool_withdrawals
  ADD COLUMN IF NOT EXISTS sol_lamports bigint NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS coin_lamports bigint NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS tokens_out bigint NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS coin_paid_in text;

ALTER TABLE coin_pools ADD COLUMN IF NOT EXISTS buyback_lamports bigint NOT NULL DEFAULT 0;

ALTER TABLE vault_state ADD COLUMN IF NOT EXISTS buyback_spent_lamports bigint NOT NULL DEFAULT 0;

CREATE TABLE IF NOT EXISTS buybacks (
  id bigserial PRIMARY KEY,
  slug text NOT NULL REFERENCES markets(slug),
  lamports bigint NOT NULL,
  tokens_burned bigint NOT NULL DEFAULT 0,
  status text NOT NULL DEFAULT 'pending',
  attempted_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS buybacks_slug_idx ON buybacks (slug, created_at DESC);
