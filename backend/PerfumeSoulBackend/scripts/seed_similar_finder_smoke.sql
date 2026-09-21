INSERT INTO brands (id, brand)
VALUES
    (91001, 'Smoke Selected Brand'),
    (91002, 'Smoke Candidate Brand'),
    (91003, 'Smoke Unclassified Brand')
ON CONFLICT (id) DO UPDATE SET brand = EXCLUDED.brand;

INSERT INTO notes (id, name, name_en)
VALUES
    (91001, 'Бергамот', ' Bergamot '),
    (91002, 'Жасмин', ' Jasmine ')
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    name_en = EXCLUDED.name_en;

INSERT INTO accords (id, name)
VALUES (91001, 'smoke-citrus')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

INSERT INTO perfumes (
    id,
    perfume_name,
    brand_id,
    longevity_score,
    sillage_score,
    market_segment
)
VALUES
    (91001, 'Smoke Selected', 91001, 7, 7, 'daily'),
    (93001, 'Smoke Candidate', 91002, 7, 7, 'daily'),
    (93002, 'Smoke Unclassified', 91003, 7, 7, 'unclassified')
ON CONFLICT (id) DO UPDATE SET
    perfume_name = EXCLUDED.perfume_name,
    brand_id = EXCLUDED.brand_id,
    longevity_score = EXCLUDED.longevity_score,
    sillage_score = EXCLUDED.sillage_score,
    market_segment = EXCLUDED.market_segment;

INSERT INTO perfumes (
    id,
    perfume_name,
    brand_id,
    longevity_score,
    sillage_score,
    market_segment
)
SELECT
    filler_id,
    'Smoke Filler ' || filler_id,
    91001,
    5,
    5,
    'daily'
FROM generate_series(92000, 92999) AS filler_id
ON CONFLICT (id) DO UPDATE SET
    perfume_name = EXCLUDED.perfume_name,
    brand_id = EXCLUDED.brand_id,
    longevity_score = EXCLUDED.longevity_score,
    sillage_score = EXCLUDED.sillage_score,
    market_segment = EXCLUDED.market_segment;

INSERT INTO perfume_notes (perfume_id, note_id, note_type, sort_order)
VALUES
    (91001, 91001, 'top', 0),
    (91001, 91002, 'middle', 1),
    (93001, 91001, 'top', 0),
    (93002, 91001, 'top', 0),
    (93002, 91002, 'middle', 1)
ON CONFLICT (perfume_id, note_id, note_type) DO UPDATE SET sort_order = EXCLUDED.sort_order;

INSERT INTO perfume_accords (perfume_id, accord_id, weight)
VALUES
    (91001, 91001, 1),
    (93001, 91001, 1),
    (93002, 91001, 1)
ON CONFLICT (perfume_id, accord_id) DO UPDATE SET weight = EXCLUDED.weight;
