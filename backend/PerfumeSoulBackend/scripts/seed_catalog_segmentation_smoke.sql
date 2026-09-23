-- CI smoke test only. Do not run against a working or imported database.
INSERT INTO brands (id, brand)
VALUES
    (94001, 'Chanel'),
    (94002, 'Creed'),
    (94003, 'Zara')
ON CONFLICT (id) DO UPDATE SET brand = EXCLUDED.brand;

INSERT INTO perfumes (id, perfume_name, brand_id, market_segment)
VALUES
    (94001, 'Smoke Chanel', 94001, NULL),
    (94002, 'Smoke Creed', 94002, 'unclassified'),
    (94003, 'Smoke Zara', 94003, 'unclassified')
ON CONFLICT (id) DO UPDATE SET
    perfume_name = EXCLUDED.perfume_name,
    brand_id = EXCLUDED.brand_id,
    market_segment = EXCLUDED.market_segment;
