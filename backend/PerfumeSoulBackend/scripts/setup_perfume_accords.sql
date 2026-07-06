CREATE TABLE IF NOT EXISTS accords (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS perfume_accords (
    id SERIAL PRIMARY KEY,
    perfume_id INTEGER NOT NULL REFERENCES perfumes(id) ON DELETE CASCADE,
    accord_id INTEGER NOT NULL REFERENCES accords(id) ON DELETE CASCADE,
    weight DOUBLE PRECISION NOT NULL CHECK (weight >= 0),
    UNIQUE (perfume_id, accord_id)
);

CREATE INDEX IF NOT EXISTS idx_perfume_accords_perfume_id
    ON perfume_accords (perfume_id);

CREATE INDEX IF NOT EXISTS idx_perfume_accords_accord_id
    ON perfume_accords (accord_id);

CREATE INDEX IF NOT EXISTS idx_perfume_accords_perfume_weight
    ON perfume_accords (perfume_id, weight DESC);
