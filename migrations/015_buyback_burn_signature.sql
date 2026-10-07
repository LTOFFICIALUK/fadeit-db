CREATE UNIQUE INDEX IF NOT EXISTS house_buybacks_burn_sig_uidx
  ON house_buybacks (burn_signature)
  WHERE burn_signature IS NOT NULL AND burn_signature <> '';
