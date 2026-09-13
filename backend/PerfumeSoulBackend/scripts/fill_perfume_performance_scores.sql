-- Baseline coverage for the app's required 1...10 performance fields.
-- Run after catalog import on a fresh database:
--   psql "$DATABASE_URL" -f scripts/fill_perfume_performance_scores.sql
--
-- This fills only NULL values and is therefore idempotent. These are baseline
-- values for recommendation continuity; verified public aggregate values are
-- applied later through explicit manual updates and never overwritten here.
UPDATE perfumes
SET longevity_score = CASE
        WHEN perfume_name ILIKE '%Elixir%' THEN 9
        WHEN perfume_name ILIKE '%Extrait%' OR perfume_name ILIKE '%Parfum%' OR perfume_name ILIKE '%Intense%' THEN 8
        WHEN perfume_name ILIKE '%Cologne%' OR perfume_name ILIKE '%Eau Fraiche%' THEN 5
        ELSE 6
    END,
    sillage_score = CASE
        WHEN perfume_name ILIKE '%Elixir%' THEN 9
        WHEN perfume_name ILIKE '%Extrait%' OR perfume_name ILIKE '%Parfum%' OR perfume_name ILIKE '%Intense%' THEN 7
        WHEN perfume_name ILIKE '%Cologne%' OR perfume_name ILIKE '%Eau Fraiche%' THEN 4
        ELSE 6
    END
WHERE longevity_score IS NULL OR sillage_score IS NULL;
