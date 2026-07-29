# PerfumeSoulBackend

Backend service for Perfume Soul, built with Vapor.

## Local run

Open terminal and go to the backend folder:

```bash
cd /Users/afon.com/Desktop/iOS-разработка/Perfume_Soul/PerfumeSoul/backend/PerfumeSoulBackend
```

Build the project:

```bash
swift build
```

Configure the database connection in `.env`:

```bash
cp .env.example .env
```

Then set `DATABASE_URL`, for example:

```bash
DATABASE_URL=postgresql://postgres:your-password@localhost:5432/postgres
```

Schema changes for perfume profile metadata and accords are now applied by Fluent migrations during app startup.
The same migration also adds `market_segment` to `perfumes` and backfills it with `luxury`, `daily`, or `niche`.

Seed/backfill steps remain separate and should be run manually for local data population.

Seed perfumery history into PostgreSQL:

```bash
psql "$DATABASE_URL" -f scripts/seed_perfumery_history.sql
```

Seed daily horoscopes into PostgreSQL:

```bash
psql "$DATABASE_URL" -f scripts/seed_daily_horoscopes.sql
```

Backfill perfume profile metadata:

```bash
psql "$DATABASE_URL" -f scripts/fill_perfume_profile_metadata.sql
```

Backfill perfume accords:

```bash
psql "$DATABASE_URL" -f scripts/fill_perfume_accords.sql
```

Run the server:

```bash
swift run PerfumeSoulBackend
```

Run tests:

```bash
swift test
```

## Open in browser

After `swift run`, open:

- http://127.0.0.1:8080/perfumery-history
- http://127.0.0.1:8080/horoscope/daily
- http://127.0.0.1:8080/perfumes?searchText=dior&offset=0&limit=10
- http://127.0.0.1:8080/perfumes/1/notes
- http://127.0.0.1:8080/perfumes/recommendations?perfumeIDs=1,2,3
- `POST` http://127.0.0.1:8080/personal-perfumes

Expected response on `/perfumery-history`:

```json
{
  "year": 1957,
  "perfumeName": "Dior Diorissimo",
  "shortStory": "Один из самых культовых ароматов Dior с нотой ландыша.",
  "fullStory": "12 мая 1957 года Дом Dior представил миру аромат Diorissimo — утончённый цветочный букет, вдохновлённый ландышем, любимым цветком Кристиана Диора.",
  "imageUrl": ""
}
```

Expected response on `/horoscope/daily`:

```json
[
  {
    "sign": "aries",
    "energyOfDay": "Сегодня хороший день для инициативы и быстрых решений."
  },
  {
    "sign": "taurus",
    "energyOfDay": "День подойдет для спокойной концентрации, практичных покупок и наведения порядка в делах."
  }
]
```

Expected response on `/perfumes/recommendations?perfumeIDs=1,2,3`:

```json
[
  {
    "id": 12,
    "perfumeName": "Eros",
    "brandName": "Versace",
    "matchingNotes": ["Бергамот", "Ветивер", "Кедр"],
    "matchPercentage": 78,
    "longevityScore": 8,
    "sillageScore": 7
  }
]
```

Example request for `/personal-perfumes`:

```json
{
  "sun": "leo",
  "moon": "cancer",
  "ascendant": "scorpio",
  "elementBalance": {
    "fire": 45,
    "earth": 15,
    "air": 10,
    "water": 30
  }
}
```

Expected response on `/personal-perfumes`:

```json
[
  {
    "id": 24,
    "perfumeName": "Ombre Leather",
    "brandName": "Tom Ford",
    "marketSegment": "luxury",
    "matchingNotes": ["Шафран", "Кожа"],
    "matchingAccords": ["leather", "amber"],
    "matchPercentage": 82,
    "longevityScore": 8,
    "sillageScore": 7
  }
]
```

## Recommendation logic

`GET /perfumes/recommendations` is no longer loaded from a JSON fixture.

The endpoint now builds recommendations from PostgreSQL perfume data:

- input: `1` to `3` selected perfume ids
- source data: brand, perfume name, top/middle/base notes, accords, profile metadata, longevity score, sillage score
- output: up to `5` similar perfumes excluding the selected ones

Current backend responsibility:

- load perfume data from PostgreSQL
- build the recommendation candidate list
- exclude the selected perfumes themselves
- calculate the final `matchPercentage`
- deduplicate close perfume clones by signature
- apply deterministic tie-breakers for equal scores
- return matching notes and wear data for the client

The backend is now the single source of truth for recommendation scoring.

## Personal perfume logic

`POST /personal-perfumes` builds a profile-based perfume selection from PostgreSQL. It does not call AI, external recommendation services, or secret API-backed services.

Input:

- `sun`
- `moon`
- `ascendant`
- `elementBalance`

Source perfume data:

- brand
- perfume name
- top, middle, and base notes
- accords
- `fragrance_family`
- `mood_profile`
- `style_profile`
- `longevity_score`
- `sillage_score`
- `market_segment`

The loader maps natal profile data into aromatic preferences:

- Sun controls the core fragrance family, accord, and note direction.
- Moon controls emotional comfort: soft, fresh, sweet, watery, calm, cozy, or intimate facets.
- Ascendant controls the outer impression: brightness, style, intensity, and sillage.
- Element balance strengthens fire, earth, air, and water perfume vectors proportionally.

Current MVP score:

```text
finalScore =
    accordsMatch * 0.35 +
    notesMatch * 0.30 +
    familyMoodStyleMatch * 0.25 +
    longevitySillageMatch * 0.10
```

The endpoint normalizes `finalScore` to `matchPercentage` and returns:

- top 3 where `market_segment = luxury`
- top 3 where `market_segment = daily`
- top 3 where `market_segment = niche`

The MVP does not rebalance between segments. If fewer than 3 perfumes exist in a segment, it returns only the available valid perfumes for that segment.

## Tests

Backend recommendation logic has focused tests for:

- duplicate signature deduplication
- empty accords / optional metadata scoring
- deterministic tie-breakers for equal scores
- personal perfume top 3 selection per market segment
- deterministic personal perfume segment ordering

## Notes for me

- Backend is separate from the iOS app and lives in `backend/PerfumeSoulBackend`.
- First build can take a long time because Swift Package Manager downloads and compiles dependencies.
- `GET /perfumery-history` now reads from PostgreSQL, so `perfumery_history` must be seeded before local run.
- `GET /perfumes` now reads from PostgreSQL, so the local database must be running and contain `brands` and `perfumes`.
- `GET /perfumes/recommendations` also reads from PostgreSQL and depends on populated `perfumes`, `brands`, `notes`, `perfume_notes`, `accords`, and `perfume_accords`.
- `POST /personal-perfumes` depends on populated `market_segment`, profile metadata, notes, and accords.
- `GET /horoscope/daily` now reads from PostgreSQL, so `daily_horoscopes` must be seeded before local run.
- quiz data still uses packaged backend resources under `Sources/PerfumeSoulBackend/Requests/quiz-of-the-day/Resources`.
- If the server is running, stop it with `Control + C`.
