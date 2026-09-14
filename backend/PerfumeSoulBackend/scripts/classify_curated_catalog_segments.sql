-- First-pass market segmentation for the curated catalogue.
-- The classification is deliberately conservative: only brands with an unambiguous
-- public market position are assigned. Everything else remains unclassified for review.
-- Re-running this script preserves any segment set by a later manual review.

BEGIN;

UPDATE perfumes AS perfume
SET market_segment = 'niche'
FROM brands AS brand
WHERE perfume.brand_id = brand.id
  AND perfume.market_segment = 'unclassified'
  AND lower(btrim(brand.brand)) IN (
    'aaron terence hughes', 'acqua di parma', 'alexandre j', 'amouage',
    'amouroud', 'arabian oud', 'areej le dore', 'atelier cologne',
    'atelier des ors', 'atkinsons', 'bdk parfums', 'boadicea the victorious',
    'bohoboco', 'bois 1920', 'bond no 9', 'bon parfumeur', 'bortnikoff',
    'brecourt', 'byredo', 'caron', 'carner barcelona', 'carthusia',
    'clive christian', 'commodity', 'comptoir sud pacifique', 'creed',
    'd orsay', 'diptyque', 'ds durga', 'eau d italie', 'electimuss',
    'ellis brooklyn', 'etat libre d orange', 'evody parfums', 'ex nihilo',
    'filippo sorcinelli', 'floris', 'floraiku', 'fragrance du bois',
    'fragonard', 'franck boclet', 'frapin', 'frederic malle', 'fueguia 1833',
    'giardino benessere', 'goutal', 'gritti', 'haute fragrance company hfc',
    'histoires de parfums', 'houbigant', 'house of sillage', 'il profvmo',
    'initio', 'james heeley', 'jo malone london', 'jovoy paris',
    'jul et mad paris', 'juliette has a gun', 'kajal', 'kilian paris',
    'l artisan parfumeur', 'laboratorio olfattivo', 'laurent mazzone parfums',
    'les liquides imaginaires', 'les parfums de rosine', 'lorenzo pazzaglia',
    'lorenzo villoresi', 'lubin', 'm mancera', 'm micallef',
    'maison francis kurkdjian', 'maitre parfumeur et gantier', 'mancera',
    'maria candida gentile', 'masque milano', 'mdci parfums', 'memo paris',
    'miller harris', 'mind games', 'mizensir', 'molinard', 'mona di orio',
    'monotheme venezia', 'montale', 'moresque', 'navitus parfums',
    'nicolai parfumeur createur', 'nishane', 'nobile 1942', 'olfactive studio',
    'ormonde jayne', 'oriza l legrand', 'parfum d empire', 'parfums de marly',
    'penhaligon s', 'perris monte carlo', 'phlur', 'pierre guillaume paris',
    'rance 1795', 'reminiscence', 'robert piguet', 'roja dove', 'royal crown',
    'santa maria novella', 'sapientiae niche', 'serge lutens', 'shay blue london',
    'sospiro perfumes', 'stephane humbert lucas 777', 'tauer perfumes',
    'teo cabanel', 'thameen', 'the different company', 'the house of oud',
    'the merchant of venice', 'tiziana terenzi', 'v canto', 'vilhelm parfumerie',
    'widian', 'xerjoff', 'zaharoff', 'zoologist perfumes'
  );

UPDATE perfumes AS perfume
SET market_segment = 'luxury'
FROM brands AS brand
WHERE perfume.brand_id = brand.id
  AND perfume.market_segment = 'unclassified'
  AND lower(btrim(brand.brand)) IN (
    'adolfo dominguez', 'alfred dunhill', 'angel schlesser', 'anna sui',
    'aramis', 'azzaro', 'balenciaga', 'baldessarini', 'blumarine',
    'bottega veneta', 'boucheron', 'burberry', 'bvlgari', 'cacharel',
    'calvin klein', 'carolina herrera', 'carven', 'cartier', 'cerruti',
    'chanel', 'chloe', 'chopard', 'clinique', 'coach', 'comme des garcons',
    'costume national', 'courreges', 'davidoff', 'dior', 'dolce & gabbana',
    'donna karan', 'dsquared2', 'elie saab', 'emanuel ungaro',
    'ermenegildo zegna', 'escada', 'estee lauder', 'eisenberg', 'etro',
    'fendi', 'fresh', 'gianfranco ferre', 'giorgio armani',
    'giorgio beverly hills', 'givenchy', 'gres', 'gucci', 'guerlain',
    'hermes', 'hugo boss', 'iceberg', 'issey miyake', 'jean patou',
    'jean paul gaultier', 'jesus del pozo', 'jimmy choo', 'joop', 'juicy couture',
    'karl lagerfeld', 'kayali fragrances', 'kenzo', 'kenneth cole',
    'korloff paris', 'la perla', 'lacoste fragrances', 'lalique', 'lancome',
    'lanvin', 'laura biagiotti', 'loewe', 'lolita lempicka', 'louis vuitton',
    'maison margiela', 'marc jacobs', 'mauboussin', 'michael kors', 'montblanc',
    'moschino', 'mugler', 'narciso rodriguez', 'nina ricci', 'oscar de la renta',
    'paco rabanne', 'paul smith', 'pierre balmain', 'prada', 'princesse marina de bourbon',
    'ralph lauren', 'roberto cavalli', 'rochas', 's t dupont', 'salvador dali',
    'salvatore ferragamo', 'shiseido', 'sisley', 'sonia rykiel', 'ted lapidus',
    'tocca', 'tom ford', 'trussardi', 'valentino', 'van cleef arpels',
    'vera wang', 'versace', 'viktor rolf', 'yohji yamamoto', 'yves saint laurent',
    'zadig voltaire'
  );

UPDATE perfumes AS perfume
SET market_segment = 'daily'
FROM brands AS brand
WHERE perfume.brand_id = brand.id
  AND perfume.market_segment = 'unclassified'
  AND lower(btrim(brand.brand)) IN (
    'adidas', 'afnan', 'ajmal', 'al haramain perfumes', 'alexandria fragrances',
    'antonio banderas', 'ard al zaafaran', 'ariana grande', 'armaf', 'avon',
    'banana republic', 'bath body works', 'bentley', 'benetton', 'beyonce',
    'britney spears', 'brocard', 'bruno banani', 'cafe parfums', 'christian audigier',
    'christina aguilera', 'clean', 'coty', 'cuba paris', 'david beckham', 'diesel',
    'dzintars', 'english laundry', 'esteban', 'eudora', 'faberlic', 'ferrari',
    'franck olivier', 'ghost', 'granado', 'guess', 'halloween', 'harajuku lovers',
    'hollister', 'jacomo', 'jacques bogart', 'jaguar', 'jennifer lopez',
    'jeanne arthes', 'jequiti', 'kkw fragrance', 'korres', 'l erbolario',
    'l occitane au bresil', 'l occitane en provence', 'la rive', 'lattafa perfumes',
    'liz claiborne', 'lulu castagnette', 'lush', 'mahogany', 'maison alhambra',
    'mary kay', 'masaki matsushima', 'mercedes benz', 'mexx', 'michel germain',
    'naomi campbell', 'natura', 'nautica', 'o boticario', 'oriflame',
    'paris elysees', 'parfums genty', 'paris hilton', 'perry ellis', 'phebo',
    'playboy', 'police', 'puma', 'rasasi', 'roger gallet', 'sarah jessica parker',
    'sergio tacchini', 'shakira', 'swiss arabian', 'tesori d oriente',
    'the body shop', 'thera cosmeticos', 'tommy bahama', 'tommy hilfiger',
    'tous', 'ulric de varens', 'victoria s secret', 'vince camuto', 'yardley',
    'yves rocher', 'zara'
  );

COMMIT;
