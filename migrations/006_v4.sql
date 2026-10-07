ALTER TABLE markets
  ADD COLUMN IF NOT EXISTS paused boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS tier integer NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS r_ref_lamports bigint NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS change_6h numeric NOT NULL DEFAULT 0;

ALTER TABLE positions
  ADD COLUMN IF NOT EXISTS fee_lamports bigint NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS premium_paid_lamports bigint NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS strike numeric;

CREATE TABLE IF NOT EXISTS price_samples (
  slug text NOT NULL REFERENCES markets(slug) ON DELETE CASCADE,
  price numeric NOT NULL,
  reserve_lamports bigint NOT NULL,
  recorded_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS price_samples_slug_idx ON price_samples (slug, recorded_at DESC);

CREATE TABLE IF NOT EXISTS vault_state (
  id integer PRIMARY KEY CHECK (id = 1),
  buyback_lamports bigint NOT NULL DEFAULT 0,
  depositor_yield_lamports bigint NOT NULL DEFAULT 0,
  incentive_lamports bigint NOT NULL DEFAULT 0,
  treasury_lamports bigint NOT NULL DEFAULT 0,
  buffer_lamports bigint NOT NULL DEFAULT 0
);

INSERT INTO vault_state (id) VALUES (1) ON CONFLICT (id) DO NOTHING;

UPDATE positions SET status = 'void'
WHERE status = 'open' AND deposit_signature IS NULL;
