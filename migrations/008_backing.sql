ALTER TABLE pool_shares
  ADD COLUMN IF NOT EXISTS payout_mode text NOT NULL DEFAULT 'sol';

CREATE TABLE IF NOT EXISTS pool_withdrawals (
  id bigserial PRIMARY KEY,
  signature text UNIQUE NOT NULL,
  wallet text NOT NULL,
  pool text NOT NULL,
  lamports bigint NOT NULL,
  epoch_ts timestamptz NOT NULL,
  status text NOT NULL DEFAULT 'queued'
);
