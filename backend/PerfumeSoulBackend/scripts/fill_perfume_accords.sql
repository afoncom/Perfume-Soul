BEGIN;

DELETE FROM perfume_accords;

WITH note_to_accord(note_name, accord_name, base_weight) AS (
    VALUES
        ('Амбра', 'amber', 1.0),
        ('Амброксан', 'amber', 1.0),
        ('Амброксан', 'musky', 0.3),
        ('Апельсиновый цвет', 'citrus', 0.3),
        ('Апельсиновый цвет', 'floral', 1.0),
        ('Бергамот', 'citrus', 1.0),
        ('Бергамот', 'fresh', 0.4),
        ('Бобы тонка', 'amber', 0.5),
        ('Бобы тонка', 'gourmand', 0.8),
        ('Ваниль', 'amber', 0.4),
        ('Ваниль', 'gourmand', 1.0),
        ('Ветивер', 'earthy', 0.6),
        ('Ветивер', 'woody', 1.0),
        ('Герань', 'aromatic', 0.6),
        ('Герань', 'floral', 0.5),
        ('Герань', 'green', 0.2),
        ('Грейпфрут', 'citrus', 1.0),
        ('Грейпфрут', 'fresh', 0.4),
        ('Грейпфрут', 'fruity', 0.2),
        ('Груша', 'fruity', 1.0),
        ('Жасмин', 'floral', 1.0),
        ('Имбирь', 'aromatic', 0.2),
        ('Имбирь', 'fresh', 0.3),
        ('Имбирь', 'spicy', 0.8),
        ('Инжир', 'fruity', 0.8),
        ('Инжир', 'green', 0.5),
        ('Ирис', 'floral', 0.9),
        ('Ирис', 'powdery', 0.8),
        ('Кардамон', 'aromatic', 0.3),
        ('Кардамон', 'spicy', 1.0),
        ('Кедр', 'woody', 1.0),
        ('Кожа', 'leather', 1.0),
        ('Кокос', 'gourmand', 0.5),
        ('Кокос', 'fruity', 0.4),
        ('Кофе', 'gourmand', 1.0),
        ('Лабданум', 'amber', 0.9),
        ('Лабданум', 'resinous', 0.6),
        ('Лаванда', 'aromatic', 1.0),
        ('Лаванда', 'fresh', 0.3),
        ('Ладан', 'resinous', 1.0),
        ('Ладан', 'smoky', 0.5),
        ('Лимон', 'citrus', 1.0),
        ('Лимон', 'fresh', 0.5),
        ('Можжевельник', 'aromatic', 0.8),
        ('Можжевельник', 'fresh', 0.2),
        ('Можжевельник', 'woody', 0.4),
        ('Морские ноты', 'fresh', 0.3),
        ('Морские ноты', 'marine', 1.0),
        ('Мускатный орех', 'spicy', 1.0),
        ('Мускус', 'musky', 1.0),
        ('Мускус', 'powdery', 0.2),
        ('Мята', 'aromatic', 0.6),
        ('Мята', 'fresh', 1.0),
        ('Мята', 'green', 0.4),
        ('Нероли', 'citrus', 0.5),
        ('Нероли', 'floral', 0.9),
        ('Нероли', 'fresh', 0.2),
        ('Палисандр', 'woody', 1.0),
        ('Пачули', 'earthy', 0.6),
        ('Пачули', 'woody', 0.8),
        ('Перец', 'spicy', 1.0),
        ('Роза', 'floral', 1.0),
        ('Розовый перец', 'spicy', 1.0),
        ('Ром', 'boozy', 1.0),
        ('Ром', 'gourmand', 0.6),
        ('Сандал', 'woody', 1.0),
        ('Сычуанский перец', 'spicy', 1.0),
        ('Табак', 'gourmand', 0.4),
        ('Табак', 'leather', 0.3),
        ('Табак', 'smoky', 0.8),
        ('Уд', 'resinous', 0.4),
        ('Уд', 'smoky', 0.5),
        ('Уд', 'woody', 0.9),
        ('Чай', 'aromatic', 0.5),
        ('Чай', 'green', 0.5),
        ('Шафран', 'leather', 0.5),
        ('Шафран', 'spicy', 0.9),
        ('Яблоко', 'fruity', 1.0)
)
INSERT INTO accords (name)
SELECT DISTINCT accord_name
FROM note_to_accord
ON CONFLICT (name) DO NOTHING;

WITH note_to_accord(note_name, accord_name, base_weight) AS (
    VALUES
        ('Амбра', 'amber', 1.0),
        ('Амброксан', 'amber', 1.0),
        ('Амброксан', 'musky', 0.3),
        ('Апельсиновый цвет', 'citrus', 0.3),
        ('Апельсиновый цвет', 'floral', 1.0),
        ('Бергамот', 'citrus', 1.0),
        ('Бергамот', 'fresh', 0.4),
        ('Бобы тонка', 'amber', 0.5),
        ('Бобы тонка', 'gourmand', 0.8),
        ('Ваниль', 'amber', 0.4),
        ('Ваниль', 'gourmand', 1.0),
        ('Ветивер', 'earthy', 0.6),
        ('Ветивер', 'woody', 1.0),
        ('Герань', 'aromatic', 0.6),
        ('Герань', 'floral', 0.5),
        ('Герань', 'green', 0.2),
        ('Грейпфрут', 'citrus', 1.0),
        ('Грейпфрут', 'fresh', 0.4),
        ('Грейпфрут', 'fruity', 0.2),
        ('Груша', 'fruity', 1.0),
        ('Жасмин', 'floral', 1.0),
        ('Имбирь', 'aromatic', 0.2),
        ('Имбирь', 'fresh', 0.3),
        ('Имбирь', 'spicy', 0.8),
        ('Инжир', 'fruity', 0.8),
        ('Инжир', 'green', 0.5),
        ('Ирис', 'floral', 0.9),
        ('Ирис', 'powdery', 0.8),
        ('Кардамон', 'aromatic', 0.3),
        ('Кардамон', 'spicy', 1.0),
        ('Кедр', 'woody', 1.0),
        ('Кожа', 'leather', 1.0),
        ('Кокос', 'gourmand', 0.5),
        ('Кокос', 'fruity', 0.4),
        ('Кофе', 'gourmand', 1.0),
        ('Лабданум', 'amber', 0.9),
        ('Лабданум', 'resinous', 0.6),
        ('Лаванда', 'aromatic', 1.0),
        ('Лаванда', 'fresh', 0.3),
        ('Ладан', 'resinous', 1.0),
        ('Ладан', 'smoky', 0.5),
        ('Лимон', 'citrus', 1.0),
        ('Лимон', 'fresh', 0.5),
        ('Можжевельник', 'aromatic', 0.8),
        ('Можжевельник', 'fresh', 0.2),
        ('Можжевельник', 'woody', 0.4),
        ('Морские ноты', 'fresh', 0.3),
        ('Морские ноты', 'marine', 1.0),
        ('Мускатный орех', 'spicy', 1.0),
        ('Мускус', 'musky', 1.0),
        ('Мускус', 'powdery', 0.2),
        ('Мята', 'aromatic', 0.6),
        ('Мята', 'fresh', 1.0),
        ('Мята', 'green', 0.4),
        ('Нероли', 'citrus', 0.5),
        ('Нероли', 'floral', 0.9),
        ('Нероли', 'fresh', 0.2),
        ('Палисандр', 'woody', 1.0),
        ('Пачули', 'earthy', 0.6),
        ('Пачули', 'woody', 0.8),
        ('Перец', 'spicy', 1.0),
        ('Роза', 'floral', 1.0),
        ('Розовый перец', 'spicy', 1.0),
        ('Ром', 'boozy', 1.0),
        ('Ром', 'gourmand', 0.6),
        ('Сандал', 'woody', 1.0),
        ('Сычуанский перец', 'spicy', 1.0),
        ('Табак', 'gourmand', 0.4),
        ('Табак', 'leather', 0.3),
        ('Табак', 'smoky', 0.8),
        ('Уд', 'resinous', 0.4),
        ('Уд', 'smoky', 0.5),
        ('Уд', 'woody', 0.9),
        ('Чай', 'aromatic', 0.5),
        ('Чай', 'green', 0.5),
        ('Шафран', 'leather', 0.5),
        ('Шафран', 'spicy', 0.9),
        ('Яблоко', 'fruity', 1.0)
),
layer_multiplier(note_type, multiplier) AS (
    VALUES
        ('top', 1.0::DOUBLE PRECISION),
        ('middle', 1.15::DOUBLE PRECISION),
        ('base', 1.3::DOUBLE PRECISION)
),
aggregated_accords AS (
    SELECT
        pn.perfume_id,
        nta.accord_name,
        ROUND(SUM(nta.base_weight * lm.multiplier)::NUMERIC, 3)::DOUBLE PRECISION AS weight
    FROM perfume_notes pn
    JOIN notes n
        ON n.id = pn.note_id
    JOIN note_to_accord nta
        ON nta.note_name = n.name
    JOIN layer_multiplier lm
        ON lm.note_type = pn.note_type::TEXT
    GROUP BY
        pn.perfume_id,
        nta.accord_name
)
INSERT INTO perfume_accords (perfume_id, accord_id, weight)
SELECT
    aggregated_accords.perfume_id,
    accords.id,
    aggregated_accords.weight
FROM aggregated_accords
JOIN accords
    ON accords.name = aggregated_accords.accord_name
WHERE aggregated_accords.weight > 0
ON CONFLICT (perfume_id, accord_id) DO UPDATE
SET weight = EXCLUDED.weight;

COMMIT;
