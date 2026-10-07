ALTER TABLE coin_pools
  ADD COLUMN IF NOT EXISTS unswept_buyback_lamports bigint NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS unswept_index_lamports bigint NOT NULL DEFAULT 0;
