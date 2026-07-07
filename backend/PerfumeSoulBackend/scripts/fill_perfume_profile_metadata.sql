BEGIN;

UPDATE perfumes
SET concentration = NULL,
    fragrance_family = NULL,
    season_profile = NULL,
    occasion_profile = NULL,
    style_profile = NULL,
    gender_profile = NULL,
    mood_profile = NULL;

UPDATE perfumes
SET concentration = CASE
    WHEN perfume_name ILIKE '%eau de toilette%' THEN 'eau de toilette'
    WHEN perfume_name ILIKE '%eau de parfum%' THEN 'eau de parfum'
    WHEN perfume_name ILIKE '%le parfum%' THEN 'parfum'
    WHEN perfume_name ILIKE '% parfum%' THEN 'parfum'
    WHEN perfume_name ILIKE '%extrait%' THEN 'extrait'
    WHEN perfume_name ILIKE '%profumo%' THEN 'parfum'
    ELSE concentration
END;

UPDATE perfumes
SET concentration = concentration_map.concentration
FROM (
    VALUES
        ('Armaf', 'Club de Nuit Intense Man', 'eau de toilette'),
        ('Armaf', 'Club de Nuit Milestone', 'eau de parfum'),
        ('Armaf', 'Club de Nuit Sillage', 'eau de parfum'),
        ('Armaf', 'Club de Nuit Untold', 'eau de parfum'),
        ('Armaf', 'Odyssey Mandarin Sky', 'eau de parfum'),
        ('Burberry', 'Brit', 'eau de toilette'),
        ('Burberry', 'Goddess', 'eau de parfum'),
        ('Burberry', 'Her', 'eau de parfum'),
        ('Burberry', 'Hero', 'eau de toilette'),
        ('Burberry', 'Mr. Burberry', 'eau de toilette'),
        ('Byredo', 'Bal d''Afrique', 'eau de parfum'),
        ('Byredo', 'Bibliotheque', 'eau de parfum'),
        ('Byredo', 'Black Saffron', 'eau de parfum'),
        ('Byredo', 'Blanche', 'eau de parfum'),
        ('Byredo', 'Gypsy Water', 'eau de parfum'),
        ('Byredo', 'Mojave Ghost', 'eau de parfum'),
        ('Byredo', 'Mumbai Noise', 'eau de parfum'),
        ('Byredo', 'Rose of No Man''s Land', 'eau de parfum'),
        ('Byredo', 'Sundazed', 'eau de parfum'),
        ('Byredo', 'Super Cedar', 'eau de parfum'),
        ('Chanel', 'Allure Homme Edition Blanche', 'eau de parfum'),
        ('Chanel', 'Allure Homme Sport', 'eau de toilette'),
        ('Chanel', 'Allure Homme Sport Eau Extreme', 'eau de parfum'),
        ('Chanel', 'Bleu de Chanel', 'eau de toilette'),
        ('Chanel', 'Chance', 'eau de toilette'),
        ('Chanel', 'Chance Eau Fraiche', 'eau de toilette'),
        ('Chanel', 'Chance Eau Tendre', 'eau de toilette'),
        ('Chanel', 'Coco Mademoiselle', 'eau de parfum'),
        ('Chanel', 'Gabrielle', 'eau de parfum'),
        ('Chanel', 'No. 5', 'eau de parfum'),
        ('Chanel', 'Platinum Egoiste', 'eau de toilette'),
        ('Creed', 'Aventus', 'eau de parfum'),
        ('Creed', 'Aventus for Her', 'eau de parfum'),
        ('Creed', 'Green Irish Tweed', 'eau de parfum'),
        ('Creed', 'Himalaya', 'eau de parfum'),
        ('Creed', 'Love in White', 'eau de parfum'),
        ('Creed', 'Millesime Imperial', 'eau de parfum'),
        ('Creed', 'Original Vetiver', 'eau de parfum'),
        ('Creed', 'Royal Oud', 'eau de parfum'),
        ('Creed', 'Silver Mountain Water', 'eau de parfum'),
        ('Creed', 'Virgin Island Water', 'eau de parfum'),
        ('Dior', 'Dior Addict', 'eau de parfum'),
        ('Dior', 'Eau Sauvage', 'eau de toilette'),
        ('Dior', 'Fahrenheit', 'eau de toilette'),
        ('Dior', 'Homme', 'eau de toilette'),
        ('Dior', 'Homme Intense', 'eau de parfum'),
        ('Dior', 'Hypnotic Poison', 'eau de toilette'),
        ('Dior', 'J''adore', 'eau de parfum'),
        ('Dior', 'Miss Dior', 'eau de parfum'),
        ('Dior', 'Poison Girl', 'eau de parfum'),
        ('Dior', 'Sauvage', 'eau de toilette'),
        ('Dior', 'Sauvage Elixir', 'parfum'),
        ('Dolce & Gabbana', 'Light Blue', 'eau de toilette'),
        ('Dolce & Gabbana', 'Light Blue Eau Intense', 'eau de parfum'),
        ('Giorgio Armani', 'Acqua di Gio Profondo', 'eau de parfum'),
        ('Giorgio Armani', 'Stronger With You Intensely', 'eau de parfum'),
        ('Jean Paul Gaultier', 'Le Beau Le Parfum', 'parfum'),
        ('Jean Paul Gaultier', 'Le Male Le Parfum', 'parfum'),
        ('Jean Paul Gaultier', 'Scandal Le Parfum', 'parfum'),
        ('Maison Francis Kurkdjian', 'Baccarat Rouge 540', 'eau de parfum'),
        ('Maison Francis Kurkdjian', 'Baccarat Rouge 540 Extrait', 'extrait'),
        ('Narciso Rodriguez', 'Bleu Noir Eau de Parfum', 'eau de parfum'),
        ('Narciso Rodriguez', 'Bleu Noir Eau de Toilette', 'eau de toilette'),
        ('Narciso Rodriguez', 'For Her Eau de Parfum', 'eau de parfum'),
        ('Narciso Rodriguez', 'For Her Eau de Toilette', 'eau de toilette'),
        ('Tom Ford', 'Black Orchid', 'eau de parfum'),
        ('Tom Ford', 'Fucking Fabulous', 'eau de parfum'),
        ('Tom Ford', 'Lost Cherry', 'eau de parfum'),
        ('Tom Ford', 'Neroli Portofino', 'eau de parfum'),
        ('Tom Ford', 'Noir Extreme', 'eau de parfum'),
        ('Tom Ford', 'Ombre Leather', 'eau de parfum'),
        ('Tom Ford', 'Oud Wood', 'eau de parfum'),
        ('Tom Ford', 'Soleil Blanc', 'eau de parfum')
) AS concentration_map(brand_name, perfume_name, concentration)
JOIN brands
    ON brands.brand = concentration_map.brand_name
WHERE perfumes.brand_id = brands.id
  AND perfumes.perfume_name = concentration_map.perfume_name
  AND perfumes.concentration IS NULL;

WITH ranked_accords AS (
    SELECT
        perfume_accords.perfume_id,
        accords.name,
        perfume_accords.weight,
        ROW_NUMBER() OVER (
            PARTITION BY perfume_accords.perfume_id
            ORDER BY perfume_accords.weight DESC, accords.name ASC
        ) AS row_number
    FROM perfume_accords
    JOIN accords
        ON accords.id = perfume_accords.accord_id
),
primary_secondary AS (
    SELECT
        perfume_id,
        MAX(CASE WHEN row_number = 1 THEN name END) AS primary_accord,
        MAX(CASE WHEN row_number = 2 THEN name END) AS secondary_accord
    FROM ranked_accords
    GROUP BY perfume_id
)
UPDATE perfumes
SET fragrance_family = CASE
    WHEN primary_accord = 'citrus' AND secondary_accord IN ('fresh', 'aromatic', 'marine') THEN 'fresh citrus'
    WHEN primary_accord = 'fresh' AND secondary_accord = 'marine' THEN 'marine fresh'
    WHEN primary_accord = 'woody' AND secondary_accord = 'amber' THEN 'woody amber'
    WHEN primary_accord = 'woody' AND secondary_accord = 'spicy' THEN 'woody spicy'
    WHEN primary_accord = 'woody' AND secondary_accord = 'fresh' THEN 'fresh woody'
    WHEN primary_accord = 'amber' AND secondary_accord = 'woody' THEN 'amber woody'
    WHEN primary_accord = 'amber' AND secondary_accord = 'spicy' THEN 'amber spicy'
    WHEN primary_accord = 'floral' AND secondary_accord = 'fruity' THEN 'floral fruity'
    WHEN primary_accord = 'floral' AND secondary_accord = 'fresh' THEN 'fresh floral'
    WHEN primary_accord = 'gourmand' AND secondary_accord = 'amber' THEN 'amber gourmand'
    WHEN primary_accord = 'leather' AND secondary_accord = 'woody' THEN 'woody leather'
    WHEN primary_accord = 'aromatic' AND secondary_accord = 'woody' THEN 'woody aromatic'
    WHEN primary_accord = 'aromatic' AND secondary_accord = 'fresh' THEN 'fresh aromatic'
    WHEN primary_accord IS NOT NULL AND secondary_accord IS NOT NULL THEN primary_accord || ' ' || secondary_accord
    ELSE primary_accord
END
FROM primary_secondary
WHERE perfumes.id = primary_secondary.perfume_id;

UPDATE perfumes
SET season_profile = CASE
    WHEN perfume_name ILIKE ANY (ARRAY[
        '%summer%',
        '%sun%',
        '%swim%',
        '%sailing%',
        '%water%',
        '%sea%',
        '%ocean%',
        '%fraiche%',
        '%afternoon%'
    ]) THEN 'spring summer'
    WHEN fragrance_family IN ('fresh citrus', 'marine fresh', 'floral citrus', 'floral fruity', 'fresh floral') THEN 'spring summer'
    WHEN fragrance_family IN ('woody amber', 'amber woody', 'amber spicy', 'amber gourmand', 'woody spicy', 'woody leather') THEN 'autumn winter'
    WHEN fragrance_family IN ('woody citrus', 'fresh woody', 'woody aromatic', 'woody floral', 'floral woody') THEN 'spring autumn'
    WHEN concentration IN ('parfum', 'extrait') THEN 'autumn winter'
    ELSE 'all season'
END;

UPDATE perfumes
SET occasion_profile = CASE
    WHEN perfume_name ILIKE ANY (ARRAY[
        '%vip%',
        '%212%',
        '%ultra%',
        '%society%',
        '%million%',
        '%scandal%'
    ]) THEN 'night out social party'
    WHEN perfume_name ILIKE ANY (ARRAY[
        '%garden%',
        '%sunday%',
        '%rain%',
        '%harmony%',
        '%bath%',
        '%bay%',
        '%fig%'
    ]) THEN 'day relaxed intimate'
    WHEN perfume_name ILIKE ANY (ARRAY[
        '%sport%',
        '%swim%',
        '%water%',
        '%fraiche%',
        '%day%',
        '%h24%'
    ]) THEN 'day casual active'
    WHEN perfume_name ILIKE ANY (ARRAY[
        '%noir%',
        '%black%',
        '%oud%',
        '%tobacco%',
        '%elixir%',
        '%intense%',
        '%extreme%',
        '%extrait%',
        '%fabulous%'
    ]) THEN 'evening special date'
    WHEN perfume_name ILIKE ANY (ARRAY[
        '%rose%',
        '%love%',
        '%blush%',
        '%girl%',
        '%fleur%',
        '%flower%',
        '%gabrielle%'
    ]) THEN 'day date social'
    WHEN concentration = 'eau de toilette' THEN 'day office casual'
    WHEN concentration IN ('parfum', 'extrait') THEN 'evening formal special'
    WHEN fragrance_family IN ('amber gourmand', 'amber spicy', 'woody leather', 'woody spicy') THEN 'evening social date'
    ELSE 'day evening social'
END;

UPDATE perfumes
SET style_profile = CASE
    WHEN perfume_name ILIKE ANY (ARRAY[
        '%vip%',
        '%212%',
        '%million%',
        '%society%',
        '%scandal%'
    ]) THEN 'glamorous extrovert party'
    WHEN perfume_name ILIKE ANY (ARRAY[
        '%garden%',
        '%bay%',
        '%fig%',
        '%rain%',
        '%sunday%',
        '%harmony%',
        '%bath%'
    ]) THEN 'green airy relaxed'
    WHEN perfume_name ILIKE ANY (ARRAY[
        '%gentleman%',
        '%l''homme%',
        '%uomo%',
        '%habit%',
        '%egoiste%',
        '%homme%'
    ]) THEN 'tailored masculine refined'
    WHEN perfume_name ILIKE ANY (ARRAY[
        '%rose%',
        '%blush%',
        '%a la rose%',
        '%delina%'
    ]) THEN 'rose romantic luxe'
    WHEN perfume_name ILIKE ANY (ARRAY[
        '%vanille%',
        '%tonka%',
        '%cola%',
        '%candy%',
        '%angel%',
        '%share%',
        '%devotion%'
    ]) THEN 'cozy gourmand rich'
    WHEN perfume_name ILIKE ANY (ARRAY[
        '%lemon%',
        '%bergamote%',
        '%mandarine%',
        '%orange%',
        '%lime%'
    ]) THEN 'citrus luminous clean'
    WHEN perfume_name ILIKE ANY (ARRAY[
        '%sport%',
        '%blue%',
        '%bleu%',
        '%ocean%',
        '%water%',
        '%fraiche%',
        '%imagination%',
        '%swim%',
        '%sailing%'
    ]) THEN 'clean sporty modern'
    WHEN perfume_name ILIKE ANY (ARRAY[
        '%noir%',
        '%black%',
        '%oud%',
        '%leather%',
        '%tobacco%',
        '%asad%',
        '%ombre%'
    ]) THEN 'dark bold sensual'
    WHEN perfume_name ILIKE ANY (ARRAY[
        '%rose%',
        '%love%',
        '%blush%',
        '%girl%',
        '%fleur%',
        '%flower%',
        '%gabrielle%'
    ]) THEN 'romantic elegant floral'
    WHEN perfume_name ILIKE ANY (ARRAY[
        '%vanille%',
        '%vanilla%',
        '%cherry%',
        '%candy%',
        '%angel%',
        '%share%',
        '%cola%',
        '%princess%'
    ]) THEN 'sweet gourmand playful'
    WHEN perfume_name ILIKE ANY (ARRAY[
        '%vetiver%',
        '%bois%',
        '%wood%',
        '%cedar%',
        '%santal%',
        '%terre%',
        '%h24%'
    ]) THEN 'refined woody elegant'
    WHEN fragrance_family IN ('fresh citrus', 'marine fresh', 'woody citrus', 'fresh woody', 'fresh aromatic') THEN 'clean versatile bright'
    WHEN fragrance_family IN ('amber gourmand', 'amber spicy') THEN 'warm rich indulgent'
    WHEN fragrance_family IN ('woody amber', 'woody spicy', 'woody leather') THEN 'bold elegant warm'
    WHEN fragrance_family IN ('floral citrus', 'floral fruity', 'fresh floral') THEN 'bright feminine elegant'
    ELSE 'modern versatile elegant'
END;

UPDATE perfumes
SET gender_profile = CASE
    WHEN perfume_name ILIKE ANY (ARRAY[
        '%for her%',
        '%femme%',
        '%donna%',
        '%girl%',
        '%mademoiselle%',
        '%miss%',
        '%gabrielle%',
        '%valentina%',
        '%goddess%',
        '%blush%'
    ]) THEN 'feminine'
    WHEN perfume_name ILIKE ANY (ARRAY[
        '%men%',
        '%man%',
        '%homme%',
        '%uomo%',
        '%pour homme%',
        '%egoiste%',
        '%gentleman%',
        '%hero%',
        '%male%'
    ]) THEN 'masculine'
    WHEN fragrance_family IN ('floral citrus', 'floral fruity', 'fresh floral', 'floral woody') THEN 'feminine'
    WHEN fragrance_family IN ('woody citrus', 'woody amber', 'woody spicy', 'woody leather', 'woody aromatic') THEN 'masculine'
    ELSE 'unisex'
END;

UPDATE perfumes
SET mood_profile = CASE
    WHEN perfume_name ILIKE ANY (ARRAY[
        '%swim%',
        '%sea%',
        '%ocean%',
        '%water%',
        '%h24%',
        '%fraiche%',
        '%sailing%',
        '%afternoon%'
    ]) THEN 'airy energetic'
    WHEN perfume_name ILIKE ANY (ARRAY[
        '%rose%',
        '%love%',
        '%blush%',
        '%fleur%',
        '%flower%',
        '%do son%',
        '%gabrielle%',
        '%miss%'
    ]) THEN 'romantic soft'
    WHEN perfume_name ILIKE ANY (ARRAY[
        '%noir%',
        '%black%',
        '%oud%',
        '%leather%',
        '%tobacco%',
        '%elixir%',
        '%fabulous%',
        '%phantom%'
    ]) THEN 'dark sensual'
    WHEN perfume_name ILIKE ANY (ARRAY[
        '%vanille%',
        '%vanilla%',
        '%candy%',
        '%angel%',
        '%share%',
        '%cola%',
        '%gourmand%',
        '%princess%'
    ]) THEN 'cozy indulgent'
    WHEN perfume_name ILIKE ANY (ARRAY[
        '%vetiver%',
        '%bois%',
        '%wood%',
        '%cedar%',
        '%santal%',
        '%terre%',
        '%bibliotheque%'
    ]) THEN 'refined grounded'
    WHEN fragrance_family IN ('fresh citrus', 'marine fresh', 'fresh aromatic') THEN 'bright energetic'
    WHEN fragrance_family IN ('amber gourmand', 'amber spicy') THEN 'warm indulgent'
    WHEN fragrance_family IN ('woody amber', 'woody spicy', 'woody leather') THEN 'rich sensual'
    WHEN fragrance_family IN ('floral citrus', 'floral fruity', 'fresh floral') THEN 'bright romantic'
    ELSE 'balanced modern'
END;

UPDATE perfumes
SET season_profile = override_values.season_profile,
    occasion_profile = override_values.occasion_profile,
    style_profile = override_values.style_profile,
    gender_profile = override_values.gender_profile,
    mood_profile = override_values.mood_profile
FROM (
    VALUES
        ('Armaf', 'Club de Nuit Intense Man', 'spring autumn', 'evening social', 'smoky bold citrus', 'masculine', 'dark sensual'),
        ('Burberry', 'Hero', 'spring autumn', 'day office casual', 'modern woody clean', 'masculine', 'refined grounded'),
        ('Chanel', 'Allure Homme Sport', 'spring summer', 'day active casual', 'sporty citrus clean', 'masculine', 'airy energetic'),
        ('Chanel', 'Chance', 'spring autumn', 'day social casual', 'playful sparkling floral', 'feminine', 'bright romantic'),
        ('Chanel', 'Gabrielle', 'spring summer', 'day social date', 'radiant elegant floral', 'feminine', 'bright romantic'),
        ('Chanel', 'No. 5', 'spring autumn', 'day evening formal', 'classic elegant powdery', 'feminine', 'refined grounded'),
        ('Chanel', 'Platinum Egoiste', 'spring autumn', 'day office formal', 'metallic aromatic classic', 'masculine', 'refined grounded'),
        ('Creed', 'Love in White', 'spring summer', 'day formal bridal', 'clean romantic floral', 'feminine', 'romantic soft'),
        ('Dior', 'Eau Sauvage', 'spring summer', 'day office refined', 'classic citrus refined', 'masculine', 'bright energetic'),
        ('Dior', 'Miss Dior', 'spring summer', 'day date social', 'romantic couture floral', 'feminine', 'romantic soft'),
        ('Diptyque', 'Do Son', 'spring summer', 'day vacation social', 'airy tropical floral', 'feminine', 'romantic soft'),
        ('Diptyque', 'Fleur de Peau', 'spring autumn', 'day intimate', 'soft musky elegant', 'unisex', 'balanced modern'),
        ('Maison Margiela', 'Replica Bubble Bath', 'spring summer', 'day relaxed home', 'clean musky minimal', 'unisex', 'airy energetic'),
        ('Maison Margiela', 'Replica By the Fireplace', 'autumn winter', 'evening cozy', 'smoky cozy woody', 'unisex', 'cozy indulgent'),
        ('Maison Francis Kurkdjian', 'A la rose', 'spring summer', 'day romantic', 'rose airy elegant', 'feminine', 'romantic soft'),
        ('Maison Francis Kurkdjian', 'Aqua Universalis', 'spring summer', 'day clean office', 'minimal citrus clean', 'unisex', 'airy energetic'),
        ('Narciso Rodriguez', 'Bleu Noir Eau de Toilette', 'autumn winter', 'evening date', 'clean dark musky', 'masculine', 'dark sensual'),
        ('Parfums de Marly', 'Delina', 'spring summer', 'day social date', 'luxury rose bright', 'feminine', 'romantic soft'),
        ('Tom Ford', 'Black Orchid', 'autumn winter', 'evening formal', 'dark floral luxe', 'feminine', 'dark sensual'),
        ('Tom Ford', 'Fucking Fabulous', 'autumn winter', 'evening special', 'bold leather luxe', 'unisex', 'dark sensual'),
        ('Byredo', 'Bibliotheque', 'autumn winter', 'evening social', 'artistic fruity leather', 'unisex', 'refined grounded'),
        ('Byredo', 'Bal d''Afrique', 'spring summer', 'day social', 'vibrant woody citrus', 'unisex', 'bright energetic'),
        ('Kilian Paris', 'Black Phantom', 'autumn winter', 'evening special', 'boozy dark gourmand', 'unisex', 'dark sensual')
) AS override_values(brand_name, perfume_name, season_profile, occasion_profile, style_profile, gender_profile, mood_profile)
JOIN brands
    ON brands.brand = override_values.brand_name
WHERE perfumes.brand_id = brands.id
  AND perfumes.perfume_name = override_values.perfume_name;

COMMIT;
