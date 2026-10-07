INSERT INTO coin_pools (slug) SELECT slug FROM markets ON CONFLICT (slug) DO NOTHING;
INSERT INTO index_pool (id) VALUES (1) ON CONFLICT (id) DO NOTHING;
