CREATE TABLE IF NOT EXISTS perfumery_history (
    id SERIAL PRIMARY KEY,
    date_key TEXT NOT NULL UNIQUE,
    year INTEGER NOT NULL,
    perfume_name TEXT NOT NULL,
    short_story TEXT NOT NULL,
    full_story TEXT NOT NULL,
    image_url TEXT NOT NULL
);

INSERT INTO perfumery_history (
    date_key,
    year,
    perfume_name,
    short_story,
    full_story,
    image_url
)
VALUES (
    '2026-04-18',
    1957,
    'Dior Diorissimo',
    'Один из самых культовых ароматов Dior с нотой ландыша.',
    '12 мая 1957 года Дом Dior представил миру аромат Diorissimo — утончённый цветочный букет, вдохновлённый ландышем, любимым цветком Кристиана Диора. Парфюмер Эдмон Рудницка создал аромат, передающий нежность, свежесть и элегантность в одном флаконе. Этот аромат и сегодня остаётся одним из самых узнаваемых творений модного дома Dior.',
    ''
)
ON CONFLICT (date_key) DO UPDATE
SET
    year = EXCLUDED.year,
    perfume_name = EXCLUDED.perfume_name,
    short_story = EXCLUDED.short_story,
    full_story = EXCLUDED.full_story,
    image_url = EXCLUDED.image_url;
