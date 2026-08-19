UPDATE perfumes
SET short_description_en = COALESCE(perfumes.short_description_en, story.short_description_en),
    recommendation_reason_en = COALESCE(perfumes.recommendation_reason_en, story.recommendation_reason_en),
    full_story_en = COALESCE(perfumes.full_story_en, story.full_story_en)
FROM (
    VALUES
        (
            'Maison Francis Kurkdjian',
            'Baccarat Rouge 540',
            'A luminous amber-woody composition with saffron, airy jasmine, Ambroxan and a dry cedar trail.',
            'A good fit for someone who wants a noticeable but weightless aura: saffron adds sparkle, jasmine keeps it airy, and the amber-woody base leaves a clean, radiant trail.',
            'Baccarat Rouge 540 was created as a collaboration between Maison Francis Kurkdjian and Baccarat for the crystal house anniversary. Its name points to 540°C, the temperature associated with Baccarat crystal and its signature red color. The fragrance translates that idea into light and texture: saffron brings a warm metallic spark, jasmine and hedione create transparency, Ambroxan gives the composition a mineral amber tone, and cedar keeps the trail dry and graphic.'
        ),
        (
            'Creed',
            'Aventus',
            'A fruity-woody composition built around pineapple, bergamot, apple, blackcurrant, birch, jasmine, oakmoss and ambergris.',
            'A good fit for someone who wants energy, presence and a polished woody outline: bright fruit opens the scent, while birch, moss, musk and amber give it structure.',
            'Creed introduced Aventus in 2010 for the house''s 250th anniversary. Its concept centers on movement, strength and personal achievement, while the composition stays highly wearable: pineapple, apple, blackcurrant and bergamot lead into a drier heart shaped by birch, jasmine and woods. Oakmoss, musk, vanilla and ambergris support the recognizable modern trail that made Aventus one of the house''s most discussed fragrances.'
        ),
        (
            'Tom Ford',
            'Oud Wood',
            'A smooth spicy-woody Private Blend fragrance with oud, rosewood, cardamom, sandalwood, vetiver, tonka, vanilla and amber.',
            'A good fit for someone who wants quiet niche depth without heavy smoke: spices open the composition, oud and sandalwood add density, and vanilla with tonka softens the base.',
            'Oud Wood launched in 2007 as part of Tom Ford''s Private Blend collection and helped make oud more approachable in Western luxury perfumery. The oud here is neither rough nor overly animalic; rosewood, cardamom, sandalwood and vetiver smooth its edges. Tonka, vanilla and amber bring warmth to the base, creating a dry, refined and highly wearable woody profile.'
        )
) AS story(
    brand_name,
    perfume_name,
    short_description_en,
    recommendation_reason_en,
    full_story_en
)
JOIN brands
    ON brands.brand = story.brand_name
WHERE perfumes.brand_id = brands.id
    AND perfumes.perfume_name = story.perfume_name;
