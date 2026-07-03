# PerfumeSoul

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%2018.0%2B-f4b6c2" alt="Platform">
  <img src="https://img.shields.io/badge/UI-SwiftUI%20%2B%20UIKit-f7c7d3" alt="SwiftUI + UIKit">
  <img src="https://img.shields.io/badge/Architecture-Module%20%2B%20Presenter%20%2B%20Router-f8d9e2" alt="Architecture">
  <img src="https://img.shields.io/badge/Persistence-Core%20Data-f6c2cf" alt="Core Data">
</p>

PerfumeSoul is a Tuist-managed iOS app that combines perfume discovery, profile-based onboarding, and editorial daily content. The project uses a hybrid UIKit + SwiftUI setup, stores the user profile in Core Data, and includes a small Vapor backend for daily horoscope and perfumery-history content.

## Current App State

The repository currently contains a working application shell with onboarding, a tab bar, persistent profile storage, and several feature modules in different stages of completion.

- `WelcomeLoading` checks whether a profile already exists and routes either to onboarding or the main tab bar.
- `Calculation` creates a profile with name, birth date, birth time, and birth place.
- `ProfileDescription` and `PersonalPerfume` continue the onboarding flow with editorial and curated content.
- `Today` is the most integrated tab right now: it loads `perfumery-history` from the backend and opens a backend-driven `DayInPerfumery` details screen.
- `Discover` now includes a working `Find Similar Perfumes` flow with database-backed perfume search, backend-driven recommendations, and navigation to the shared perfume details card.
- `TodayEnergy` has its own screen and backend service layer, but the screen content is still mostly hardcoded in the current branch.

## User Flow

```text
SceneDelegate
  -> WelcomeLoading
     -> existing profile -> Main tab bar
     -> no profile      -> Calculation
                           -> ProfileDescription
                           -> PersonalPerfume
                           -> Main tab bar
```

Main tabs:

- `Today`
- `Discover`
- `Profile`
- `Settings`

## Feature Overview

### Today

- Daily energy entry card
- Aroma of the Day card
- Recommended perfumes carousel
- `This day in perfumery` card with a loading state
- `DayInPerfumery` details screen populated from the backend

Backend-backed data already used here:

- `GET /perfumery-history` returns a single history item with:
  - `year`
  - `perfumeName`
  - `shortStory`
  - `fullStory`
  - `imageUrl`
- `GET /perfumes/recommendations?perfumeIDs=1,2,3` returns up to 5 similar perfumes with:
  - `id`
  - `perfumeName`
  - `brandName`
  - `matchingNotes`
  - `matchPercentage`
  - `longevityScore`
  - `sillageScore`

### Discover

- Start quiz entry point
- Compare perfumes inputs
- Find similar perfumes flow with shared perfume database search
- Recommendations screen with top 5 matches and shared perfume details navigation

`Find Similar Perfumes` current flow:

1. The user selects 1 required perfume and may add up to 2 optional perfumes.
2. Each perfume is chosen from the shared backend-driven perfume search list.
3. The selected perfume ids are passed to `GET /perfumes/recommendations`.
4. The backend returns up to 5 similar perfumes from the database.
5. Tapping any recommendation opens the same `PerfumeDetails` screen used in the Search flow.

Current recommendation scoring:

- `70%` weighted note overlap
- `15%` longevity similarity
- `15%` sillage similarity

Weighted note overlap uses:

- `top` notes = weight `3`
- `middle` notes = weight `2`
- `base` notes = weight `1`

This keeps the first version simple, explainable, and fully based on data already stored in the database.

### Profile

- Loads the saved profile from Core Data
- Shows profile header with birth information
- Contains natal chart, element balance, personal perfumes, and extra profiles sections

Only the profile entity itself is persisted. Several profile sections still use static display data.

### Today Energy

- Separate screen exists
- Backend service for daily horoscopes exists
- `GET /horoscope/daily` returns an array of horoscope items

In the current codebase, the UI for this screen is still mostly static and not fully wired to backend data yet.

## Architecture

The app follows a consistent feature structure:

- `Module` builds dependencies
- `Presenter` handles user actions and orchestration
- `Router` performs navigation
- `ViewModel` stores screen state
- `Screen` renders SwiftUI views

Technical choices:

- `UIKit` for app lifecycle, navigation controllers, and tab bar setup
- `SwiftUI` for feature screens
- `Observation` with `@Observable` / `@Bindable`
- `Core Data` for local profile persistence
- `Tuist` for project generation
- `Vapor` backend for daily content endpoints
- localization resources in `en.lproj` and `ru.lproj`

## Repository Structure

```text
PerfumeSoul/
├── Project.swift
├── README.md
├── PerfumeSoul/
│   ├── Classes/
│   │   ├── Application/
│   │   ├── Core/
│   │   ├── Screens/
│   │   └── Services/
│   └── Resources/
├── PerfumeSoulTests/
├── PerfumeSoulUITests/
└── backend/
    └── PerfumeSoulBackend/
```

Important directories:

- `PerfumeSoul/Classes/Application` — `AppDelegate`, `SceneDelegate`
- `PerfumeSoul/Classes/Core` — networking and Core Data
- `PerfumeSoul/Classes/Services` — API and persistence services
- `PerfumeSoul/Classes/Screens` — feature modules
- `backend/PerfumeSoulBackend` — Vapor server, PostgreSQL-backed loaders, and recommendation logic

## Local Development

### Requirements

- Xcode 16+
- Tuist
- iOS 18.0+ simulator or device
- Swift 6 toolchain for the backend

### Generate and run the app

```bash
tuist generate
tuist build PerfumeSoul
```

Open `PerfumeSoul.xcodeproj` and run the `PerfumeSoul` scheme.

### Run the backend

Some screens expect the local backend at `http://127.0.0.1:8080`.

```bash
cd backend/PerfumeSoulBackend
swift run PerfumeSoulBackend
```

Available routes:

- `GET /perfumery-history`
- `GET /horoscope/daily`
- `GET /perfumes`
- `GET /perfumes/:perfumeID/notes`
- `GET /perfumes/recommendations?perfumeIDs=1,2,3`

## Testing and CI

Local commands:

```bash
tuist test PerfumeSoulTests
tuist test PerfumeSoulUITests
cd backend/PerfumeSoulBackend && swift test
```

GitHub Actions:

- runs on `push` and `pull_request` to `main`
- generates the Tuist project if needed
- runs `xcodebuild test` for the `PerfumeSoul` scheme
- uploads `xcodebuild.log` as an artifact on failure

## Notes on Current Limitations

This README reflects the codebase as it exists now, not the intended future product. A few parts are still in transition:

- `Today` mixes backend-driven content with static cards
- `TodayEnergy` backend integration is incomplete in the current branch
- several `Profile` sections are UI-complete but still use placeholder values

## Stack Summary

- Swift
- SwiftUI
- UIKit
- Core Data
- Tuist
- Vapor
- XCTest / XCUITest
