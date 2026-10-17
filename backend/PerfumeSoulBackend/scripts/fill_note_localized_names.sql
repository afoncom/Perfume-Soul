BEGIN;

-- Fill the legacy Russian-only seed rows before matching the complete catalog by English name.
\ir fill_note_english_names.sql

CREATE TEMP TABLE note_translations_import (
    english_name TEXT NOT NULL,
    russian_name TEXT NOT NULL
) ON COMMIT DROP;

\copy note_translations_import (english_name, russian_name) FROM 'Sources/PerfumeSoulBackend/Catalog/Resources/note_translations.tsv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER E'\t');

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM note_translations_import
        GROUP BY LOWER(BTRIM(english_name))
        HAVING COUNT(DISTINCT russian_name) > 1
    ) THEN
        RAISE EXCEPTION 'Conflicting Russian translations for the same English note';
    END IF;
END
$$;

UPDATE notes AS note
SET name = translation.russian_name,
    name_en = translation.english_name
FROM (
    SELECT english_name, MIN(russian_name) AS russian_name
    FROM note_translations_import
    GROUP BY english_name
) AS translation
WHERE LOWER(BTRIM(TRANSLATE(REPLACE(note.name_en, CHR(146), ''''), CHR(153) || '®™', ''))) =
    LOWER(BTRIM(translation.english_name));

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM notes AS note
        LEFT JOIN note_translations_import AS translation
            ON LOWER(BTRIM(TRANSLATE(REPLACE(note.name_en, CHR(146), ''''), CHR(153) || '®™', ''))) =
                LOWER(BTRIM(translation.english_name))
        WHERE translation.english_name IS NULL
            OR NULLIF(BTRIM(note.name), '') IS NULL
            OR NULLIF(BTRIM(note.name_en), '') IS NULL
    ) THEN
        RAISE EXCEPTION 'Some perfume notes are missing a complete Russian/English translation';
    END IF;
END
$$;

COMMIT;
