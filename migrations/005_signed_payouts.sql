ALTER TABLE chain_payouts
  ADD COLUMN IF NOT EXISTS signed_tx text,
  ADD COLUMN IF NOT EXISTS tokens_out bigint;
