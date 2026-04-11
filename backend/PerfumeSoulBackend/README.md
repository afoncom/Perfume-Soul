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

- http://127.0.0.1:8080
- http://127.0.0.1:8080/hello
- http://127.0.0.1:8080/perfumery-history/04-11

Expected response on `/hello`:

```text
Hello, world!
```

Expected response on `/perfumery-history/04-11`:

```json
{
  "dateKey": "04-11",
  "title": "Этот день в парфюмерии",
  "items": [
    {
      "year": 1921,
      "text": "В начале 1920-х Chanel No. 5 начал формировать новую эпоху в истории парфюмерии и быстро стал одним из самых узнаваемых ароматов мира."
    }
  ]
}
```

## Notes for me

- Backend is separate from the iOS app and lives in `backend/PerfumeSoulBackend`.
- First build can take a long time because Swift Package Manager downloads and compiles dependencies.
- If the server is running, stop it with `Control + C`.
