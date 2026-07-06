ALTER TABLE perfumes
    ADD COLUMN IF NOT EXISTS concentration TEXT;

ALTER TABLE perfumes
    ADD COLUMN IF NOT EXISTS fragrance_family TEXT;

ALTER TABLE perfumes
    ADD COLUMN IF NOT EXISTS season_profile TEXT;

ALTER TABLE perfumes
    ADD COLUMN IF NOT EXISTS occasion_profile TEXT;

ALTER TABLE perfumes
    ADD COLUMN IF NOT EXISTS style_profile TEXT;

ALTER TABLE perfumes
    ADD COLUMN IF NOT EXISTS gender_profile TEXT;

ALTER TABLE perfumes
    ADD COLUMN IF NOT EXISTS mood_profile TEXT;
