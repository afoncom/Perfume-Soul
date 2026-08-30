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

Backfill perfume stories and English note names:

```bash
psql "$DATABASE_URL" -f scripts/fill_perfume_story_metadata.sql
psql "$DATABASE_URL" -f scripts/fill_perfume_story_english_metadata.sql
psql "$DATABASE_URL" -f scripts/fill_note_english_names.sql
```

Run the server:

```bash
swift run PerfumeSoulBackend
```

Run tests:

```bash
swift test
```

## Docker Compose run

Docker Compose runs the backend together with PostgreSQL 18. `docker-compose.yml` is the production base file that pulls the backend image from GitHub Container Registry. `docker-compose.override.yml` is used automatically for local development and adds the local Docker build.

Create an env file from the example:

```bash
cp .env.compose.example .env
```

Set a real database password in `.env`. The same `.env` file is shared by local `swift run` and Docker Compose. Compose overrides `DATABASE_URL` for the backend container, so the local `DATABASE_URL` remains for direct Swift runs only.

```env
POSTGRES_PASSWORD=change-this-password
DATABASE_URL=postgresql://postgres:change-this-password@localhost:5432/postgres
```

Use an alphanumeric password because this value is interpolated into `DATABASE_URL`.

Start PostgreSQL and the backend:

```bash
docker compose up -d --build
```

The backend listens on `127.0.0.1:8080` on the host and connects to PostgreSQL through the internal Compose service name `postgres`. PostgreSQL is not published on a host port, and its data is stored in the `postgres_data` Docker volume. Docker Compose runs the backend with `VAPOR_ENV=production` so the local container mirrors production logging and error behavior; use `swift run PerfumeSoulBackend` for a development Vapor environment.

Check service status and logs:

```bash
docker compose ps
docker compose logs -f backend
docker compose logs -f postgres
```

Smoke check the backend and bundled quiz resources:

```bash
curl -f http://127.0.0.1:8080/health
curl -f http://127.0.0.1:8080/ready
curl -f http://127.0.0.1:8080/quiz-of-the-day
curl -f http://127.0.0.1:8080/perfumes/1/notes
```

Stop services:

```bash
docker compose down
```

### Publish backend image to GHCR

Use GitHub Container Registry for private image delivery to the VPS:

```text
ghcr.io/afoncom/perfume-soul-backend:latest
```

Create a GitHub personal access token with `write:packages` for publishing. Login locally:

```bash
echo "YOUR_GITHUB_TOKEN" | docker login ghcr.io -u afoncom --password-stdin
```

Build and push the backend image for a typical x86_64 VPS:

```bash
docker buildx build --platform linux/amd64 \
  -t ghcr.io/afoncom/perfume-soul-backend:latest \
  -t ghcr.io/afoncom/perfume-soul-backend:$(git rev-parse --short HEAD) \
  --push \
  .
```

Deploy or roll back to a specific commit tag by setting `BACKEND_IMAGE_TAG` in `.env` on the VPS:

```env
BACKEND_IMAGE_TAG=abc1234
```

### Docker seed/backfill

Fluent migrations run automatically when the backend starts. Data seed and backfill scripts still need to be run manually.

```bash
docker compose exec -T postgres \
  psql -U perfumesoul -d perfumesoul -v ON_ERROR_STOP=1 --single-transaction < scripts/seed_perfumery_history.sql

docker compose exec -T postgres \
  psql -U perfumesoul -d perfumesoul -v ON_ERROR_STOP=1 --single-transaction < scripts/seed_daily_horoscopes.sql

docker compose exec -T postgres \
  psql -U perfumesoul -d perfumesoul -v ON_ERROR_STOP=1 < scripts/fill_perfume_profile_metadata.sql

docker compose exec -T postgres \
  psql -U perfumesoul -d perfumesoul -v ON_ERROR_STOP=1 < scripts/fill_perfume_accords.sql

docker compose exec -T postgres \
  psql -U perfumesoul -d perfumesoul -v ON_ERROR_STOP=1 --single-transaction < scripts/fill_perfume_story_metadata.sql

docker compose exec -T postgres \
  psql -U perfumesoul -d perfumesoul -v ON_ERROR_STOP=1 --single-transaction < scripts/fill_perfume_story_english_metadata.sql

docker compose exec -T postgres \
  psql -U perfumesoul -d perfumesoul -v ON_ERROR_STOP=1 --single-transaction < scripts/fill_note_english_names.sql
```

### VPS deployment

Target Ubuntu 22.04 LTS, 24.04 LTS, or 26.04 LTS. Install Docker and Compose from Docker's official apt repository, then install Nginx, Certbot, and Git:

```bash
apt update
apt install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
cat > /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin nginx certbot python3-certbot-nginx git
systemctl enable docker
systemctl start docker
```

Clone the repository and create `.env`. If the repository is private, authenticate HTTPS with a GitHub personal access token that can read the repository, or use an SSH deploy key instead.

```bash
mkdir -p /opt/perfumesoul
cd /opt/perfumesoul
git clone https://github.com/afoncom/Perfume-Soul.git .
cd backend/PerfumeSoulBackend
cp .env.compose.example .env
nano .env
```

Set `COMPOSE_FILE=docker-compose.yml` in `.env` on the VPS so Compose uses the GHCR image and does not auto-merge the local build override:

```env
COMPOSE_FILE=docker-compose.yml
```

If the GHCR package is private, create a GitHub personal access token with `read:packages` and login on the VPS before pulling. Skip `docker login` if the GHCR package is public. Then pull and start the stack:

```bash
echo "YOUR_GITHUB_TOKEN" | docker login ghcr.io -u afoncom --password-stdin
docker compose pull
docker compose up -d
curl -f http://127.0.0.1:8080/health
curl -f http://127.0.0.1:8080/ready
curl -f http://127.0.0.1:8080/quiz-of-the-day
curl -f http://127.0.0.1:8080/perfumes/1/notes
```

A brand-new Docker PostgreSQL volume starts with schema only. Restore a dump from the existing database before relying on catalog endpoints; the seed/backfill scripts below do not insert `brands`, `perfumes`, `notes`, or `perfume_notes` rows.

Update an existing deployment:

```bash
cd /opt/perfumesoul
git pull
cd backend/PerfumeSoulBackend
docker compose pull
docker compose up -d
curl -f http://127.0.0.1:8080/health
curl -f http://127.0.0.1:8080/ready
curl -f http://127.0.0.1:8080/quiz-of-the-day
curl -f http://127.0.0.1:8080/perfumes/1/notes
```

Back up the Docker PostgreSQL database before updates:

```bash
cd /opt/perfumesoul/backend/PerfumeSoulBackend
mkdir -p backups
docker compose exec -T postgres \
  pg_dump --clean --if-exists -U perfumesoul perfumesoul | gzip > backups/perfumesoul-$(date +%Y%m%d%H%M%S).sql.gz
```

Restore a backup into the Docker PostgreSQL database:

```bash
cd /opt/perfumesoul/backend/PerfumeSoulBackend
docker compose stop backend
gunzip -c backups/perfumesoul-backup.sql.gz | docker compose exec -T postgres \
  psql -U perfumesoul -d perfumesoul -v ON_ERROR_STOP=1
docker compose start backend
```

Deploy a pinned image tag or roll back:

```bash
cd /opt/perfumesoul/backend/PerfumeSoulBackend
nano .env
docker compose pull
docker compose up -d
```

Nginx reverse proxy example:

```nginx
server {
    server_name api.your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Enable HTTPS after DNS points to the VPS:

```bash
certbot --nginx -d api.your-domain.com
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
