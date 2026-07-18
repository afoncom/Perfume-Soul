# PerfumeSoul

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%2018.0%2B-f4b6c2" alt="Platform">
  <img src="https://img.shields.io/badge/UI-SwiftUI%20%2B%20UIKit-f7c7d3" alt="SwiftUI + UIKit">
  <img src="https://img.shields.io/badge/Architecture-Module%20%2B%20Presenter%20%2B%20Router-f8d9e2" alt="Architecture">
  <img src="https://img.shields.io/badge/Persistence-Core%20Data-f6c2cf" alt="Core Data">
</p>

PerfumeSoul is a Tuist-managed iOS app that combines perfume discovery, profile-based onboarding, and editorial daily content. The project uses a hybrid UIKit + SwiftUI setup, stores the user profile in Core Data, and includes a Vapor backend backed by PostgreSQL for daily content, perfume search, perfume details, and perfume recommendations.

## Current App State

The repository currently contains a working application shell with onboarding, a tab bar, persistent profile storage, and several feature modules in different stages of completion.

- `WelcomeLoading` checks whether a profile already exists and routes either to onboarding or the main tab bar.
- `Calculation` creates a profile with name, birth date, birth time, and birth place.
- `ProfileDescription` and `PersonalPerfume` continue the onboarding flow with dynamic profile-based content.
- `Today` is one of the most integrated tabs right now: it loads `perfumery-history` and daily horoscopes from the backend and opens backend-driven details screens.
- `Discover` now includes a working `Find Similar Perfumes` flow with database-backed perfume search, backend-driven recommendations, and navigation to the shared perfume details card.
- `TodayEnergy` is wired to backend data and receives both the personal horoscope and the full horoscope list from the `Today` flow.

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
- `POST /personal-perfumes` returns 9 profile-based perfumes grouped by market segment with:
  - `id`
  - `perfumeName`
  - `brandName`
  - `marketSegment`
  - `matchingNotes`
  - `matchingAccords`
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
5. The backend calculates the ranking and the displayed `matchPercentage`.
6. Tapping any recommendation opens the same `PerfumeDetails` screen used in the Search flow.

Current recommendation scoring:

- `SearchPerfume` and `Find Similar Perfumes` search for real database items.
- The backend returns the final recommendation list, matching notes, and `matchPercentage`.
- The backend is the single source of truth for recommendation scoring.
- The current formula uses note overlap, distinct note coverage, accord overlap, family/concentration/profile similarity, and longevity/sillage similarity.
- Deduplication is applied on backend signatures before the final top 5 is returned.
- Deterministic tie-breakers are applied by `brandName`, `perfumeName`, and `id`.

### Profile

- Loads the saved profile from Core Data
- Shows profile header with birth information
- Contains natal chart, element balance, dynamic profile description, personal perfumes, and extra profiles sections

Only the profile entity itself is persisted. Dynamic profile sections derive their data from the saved profile and backend perfume metadata.

### Dynamic Profile Description

`ProfileDescription` is now generated on the iOS side from the same birth data that powers the natal chart:

```text
Profile from Core Data
  -> ProfileCalculationService
     -> AstronomyEngine
        -> Sun / Moon / Ascendant / element balance
  -> ProfileDescriptionBuilder
     -> title, subtitle, summary, insight cards
  -> ProfileDescriptionScreen
```

The builder is deterministic and does not call paid AI services or third-party text APIs. This keeps secrets out of the mobile app, avoids subscription limits, and makes the MVP behavior predictable.

Current template system:

- 12 Sun templates describe the user's core identity.
- 12 Moon templates describe emotional rhythm and inner needs.
- 12 Ascendant templates describe first impression and outer style.
- 4 dominant element templates describe the strongest temperament.
- 4 weak element templates describe the element that needs more conscious support.
- Synthesis rules combine Sun, Moon, Ascendant, and element balance into one summary.

Current synthesis rules cover:

- all three placements in one sign
- Sun and Moon in one sign
- all placements in one element
- Sun/Moon same element
- Sun/Ascendant same element
- Moon/Ascendant same element
- opposite Sun/Moon elements
- balanced element profile
- default layered profile

This is intentionally an MVP system. It gives a real dynamic profile without requiring thousands of text combinations. Future growth points:

- move templates into localization resources
- add richer Russian and English copy variants
- add aspects, houses, and more precise birth-place handling
- move profile-description generation to the backend only if the product later needs server-side consistency across platforms

### Personal Perfumes

`PersonalPerfume` is a backend-driven recommendation flow. The iOS app does not score perfumes locally and does not calculate `matchPercentage`.

Current data flow:

```text
ProfileCalculation
  -> PersonalPerfumePresenter
     -> PersonalPerfumeService
        -> RequestManager
           -> POST /personal-perfumes
              -> PersonalPerfumeLoader
                 -> PostgreSQL perfume data
                 -> deterministic scoring
              -> response with 9 perfumes
     -> PersonalPerfumeViewModel
  -> PersonalPerfumeScreen
```

The request sends only the already calculated natal profile data needed for matching:

- Sun sign
- Moon sign
- Ascendant sign
- element balance

The backend maps the profile into aromatic preferences:

- Sun defines the core fragrance direction: families, accords, and base taste vector.
- Moon defines emotional comfort: softness, freshness, sweetness, wateriness, calmness, and cozy notes.
- Ascendant defines outer impression: style, brightness, intensity, sillage, and perceived presence.
- Element balance strengthens the overall vector:
  - Fire: spicy, amber, leather, smoky, citrus, stronger sillage
  - Earth: woody, green, earthy, vetiver, patchouli, iris, longer wear
  - Air: fresh, citrus, aromatic, musky, clean, light
  - Water: marine, floral, soft musk, vanilla, incense, powdery, soft

Current MVP scoring is deterministic and uses:

- accord match, weighted at `0.35`
- note match, weighted at `0.30`
- fragrance family, mood, and style match, weighted at `0.25`
- longevity and sillage match, weighted at `0.10`

The backend normalizes the final score into `matchPercentage`. Perfumes are split by `marketSegment` stored on the perfume row:

- `luxury`
- `daily`
- `niche`

The endpoint returns top 3 perfumes per segment, for 9 perfumes total. If a segment has fewer than 3 valid perfumes, the MVP returns the available perfumes from that segment and does not borrow from another segment.

### Today Energy

- Separate screen exists
- Backend service for daily horoscopes exists
- `GET /horoscope/daily` returns an array of horoscope items from PostgreSQL
- The screen receives backend-driven data through the `Today` module and displays the personal horoscope plus the general list

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
- `Vapor` backend for PostgreSQL-backed content and perfume endpoints
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

Open `PerfumeSoul.xcworkspace` (or `PerfumeSoul.xcodeproj`) and run the `PerfumeSoul` scheme.

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
- `POST /personal-perfumes`

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
- several `Profile` sections are UI-complete but still use placeholder values
- recommendation quality now comes from backend scoring sources, but the perfume metadata dataset is still evolving

## Stack Summary

- Swift
- SwiftUI
- UIKit
- Core Data
- Tuist
- Vapor
- XCTest / XCUITest
