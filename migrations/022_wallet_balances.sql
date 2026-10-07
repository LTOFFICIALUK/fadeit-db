ALTER TABLE coin_pools
  ADD COLUMN IF NOT EXISTS wallet_lamports bigint NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS wallet_sampled_at timestamptz;
