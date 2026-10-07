ALTER TABLE house_buybacks ADD COLUMN IF NOT EXISTS source text NOT NULL DEFAULT 'short_fee';
ALTER TABLE house_buybacks ADD COLUMN IF NOT EXISTS pool_slug text;
ALTER TABLE house_buybacks ADD COLUMN IF NOT EXISTS wallet text;

ALTER TABLE creator_fee_claims ADD COLUMN IF NOT EXISTS tokens_burned bigint NOT NULL DEFAULT 0;
ALTER TABLE creator_fee_claims ADD COLUMN IF NOT EXISTS swap_signature text;
ALTER TABLE creator_fee_claims ADD COLUMN IF NOT EXISTS burn_signature text;

CREATE TABLE IF NOT EXISTS fee_inflows (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  pool_slug text NOT NULL,
  mint text,
  source text NOT NULL DEFAULT 'pump_creator_fee',
  lamports bigint NOT NULL,
  signature text NOT NULL UNIQUE,
  booked_to text NOT NULL DEFAULT 'seed',
  at timestamptz NOT NULL DEFAULT now()
);
