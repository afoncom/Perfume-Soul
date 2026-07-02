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

Seed perfumery history into PostgreSQL:

```bash
psql "$DATABASE_URL" -f scripts/seed_perfumery_history.sql
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

## Notes for me

- Backend is separate from the iOS app and lives in `backend/PerfumeSoulBackend`.
- First build can take a long time because Swift Package Manager downloads and compiles dependencies.
- `GET /perfumery-history` now reads from PostgreSQL, so `perfumery_history` must be seeded before local run.
- `GET /perfumes` now reads from PostgreSQL, so the local database must be running and contain `brands` and `perfumes`.
- Endpoint resources are stored under `Sources/PerfumeSoulBackend/Requests/<endpoint>/Resources`.
- If the server is running, stop it with `Control + C`.
