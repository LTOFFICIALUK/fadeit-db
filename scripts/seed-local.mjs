import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import postgres from "postgres";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const url = process.env.DATABASE_URL || "";
const blocked =
  process.env.NODE_ENV === "production" ||
  Boolean(process.env.RAILWAY_ENVIRONMENT) ||
  url.includes("railway") ||
  url.includes("rlwy.net");

if (blocked) {
  console.error("Refusing to seed a production database.");
  process.exit(1);
}
if (!url) {
  console.error("DATABASE_URL is required");
  process.exit(1);
}

const sql = postgres(url, { max: 1 });
const seed = JSON.parse(fs.readFileSync(path.join(root, "seeds/markets.json"), "utf8"));

const run = async () => {
  for (const market of seed) {
    if (market.slug !== "fake") throw new Error("Seed file may only contain the fake market.");
    await sql`
      INSERT INTO markets (
        slug, ticker, name, venue, mint, pair_address, image_url,
        price_usd, change_1h, mcap_usd, pool_depth_usd, age_hours, volume_24h_usd,
        short_oi_usd, long_oi_usd, coming_soon, paused, updated_at
      ) VALUES (
        ${market.slug}, ${market.ticker}, ${market.name}, ${market.venue}, ${market.mint},
        ${market.pairAddress}, ${market.imageUrl}, ${market.priceUsd}, ${market.change1h},
        ${market.mcapUsd}, ${market.poolDepthUsd}, ${market.ageHours}, ${market.volume24hUsd},
        0, 0, true, true, now()
      )
      ON CONFLICT (slug) DO NOTHING
    `;
  }
  console.log("seeded local fake market");
};

run()
  .then(() => sql.end())
  .catch(async (err) => {
    console.error(err instanceof Error ? err.message : err);
    await sql.end({ timeout: 1 });
    process.exit(1);
  });
