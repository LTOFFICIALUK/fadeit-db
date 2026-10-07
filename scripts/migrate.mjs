import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import postgres from "postgres";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const url = process.env.DATABASE_URL;
if (!url) {
  console.error("DATABASE_URL is required");
  process.exit(1);
}

const sql = postgres(url, {
  max: 1,
  ssl: url.includes("localhost") || url.includes("railway.internal") ? false : "require",
});

const migrate = async () => {
  await sql`
    CREATE TABLE IF NOT EXISTS schema_migrations (
      id text PRIMARY KEY,
      applied_at timestamptz NOT NULL DEFAULT now()
    )
  `;
  const dir = path.join(root, "migrations");
  const files = fs.readdirSync(dir).filter((f) => f.endsWith(".sql")).sort();
  for (const file of files) {
    const applied = await sql`SELECT 1 FROM schema_migrations WHERE id = ${file}`;
    if (applied.length) continue;
    const text = fs.readFileSync(path.join(dir, file), "utf8");
    await sql.unsafe(text);
    await sql`INSERT INTO schema_migrations (id) VALUES (${file})`;
    console.log("applied", file);
  }

  const solUsd = Number(process.env.SOL_USD || 116.95);
  await sql`
    UPDATE markets m SET
      short_oi_usd = COALESCE((
        SELECT SUM(p.size_lamports) FROM positions p
        WHERE p.slug = m.slug AND p.status = 'open' AND p.direction = 'short'
      ), 0) / 1000000000.0 * ${solUsd},
      long_oi_usd = COALESCE((
        SELECT SUM(p.size_lamports) FROM positions p
        WHERE p.slug = m.slug AND p.status = 'open' AND p.direction = 'long'
      ), 0) / 1000000000.0 * ${solUsd}
  `;

  const pub = process.env.PLATFORM_WALLET_PUBLIC_KEY;
  if (pub) {
    await sql`
      INSERT INTO platform (id, public_key, updated_at)
      VALUES (1, ${pub}, now())
      ON CONFLICT (id) DO UPDATE SET public_key = EXCLUDED.public_key, updated_at = now()
    `;
  }
  await sql`
    INSERT INTO coin_pools (slug)
    SELECT slug FROM markets
    ON CONFLICT (slug) DO NOTHING
  `;
  await sql`INSERT INTO index_pool (id) VALUES (1) ON CONFLICT (id) DO NOTHING`;
  console.log("schema ready");
};

migrate()
  .then(async () => {
    await sql.end();
  })
  .catch(async (err) => {
    console.error(err);
    await sql.end({ timeout: 1 });
    process.exit(1);
  });
