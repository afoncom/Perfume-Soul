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

Run the server:

```bash
swift run
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
- http://127.0.0.1:8080/perfumes/recommendations?perfumeIDs=1,2,3

Expected response on `/perfumery-history`:

```json
{
  "year": 1957,
  "perfumeName": "Dior Diorissimo",
  "shortStory": "Один из самых культовых ароматов Dior с нотой ландыша.",
  "fullStory": "12 мая 1957 года Дом Dior представил миру аромат Diorissimo...",
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
    "longevityScore": 8,
    "sillageScore": 7
  }
]
```

## Recommendation logic

`GET /perfumes/recommendations` is no longer loaded from a JSON fixture.

The endpoint now builds recommendations from PostgreSQL perfume data:

- input: `1` to `3` selected perfume ids
- source data: brand, perfume name, top/middle/base notes, longevity score, sillage score
- output: up to `5` similar perfumes excluding the selected ones

Current backend responsibility:

- load perfume data from PostgreSQL
- build the recommendation candidate list
- exclude the selected perfumes themselves
- return matching notes and wear data for the client

The final displayed match percentage is now calculated on the iOS client.

## Notes for me

- Backend is separate from the iOS app and lives in `backend/PerfumeSoulBackend`.
- First build can take a long time because Swift Package Manager downloads and compiles dependencies.
- `GET /perfumes` now reads from PostgreSQL, so the local database must be running and contain `brands` and `perfumes`.
- `GET /perfumes/recommendations` also reads from PostgreSQL and depends on populated `perfumes`, `brands`, `notes`, and `perfume_notes`.
- Endpoint resources are stored under `Sources/PerfumeSoulBackend/Requests/<endpoint>/Resources`.
- If the server is running, stop it with `Control + C`.
