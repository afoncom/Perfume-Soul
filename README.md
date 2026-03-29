# PerfumeSoul

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%2018.6%2B-f4b6c2" alt="Platform">
  <img src="https://img.shields.io/badge/Swift-SwiftUI%20%2B%20UIKit-f7c7d3" alt="SwiftUI + UIKit">
  <img src="https://img.shields.io/badge/Architecture-Module%20%2B%20Presenter%20%2B%20Router-f8d9e2" alt="Architecture">
  <img src="https://img.shields.io/badge/Persistence-Core%20Data-f6c2cf" alt="Core Data">
</p>

<p align="center">
  <strong>PerfumeSoul</strong> is an iOS concept app that blends fragrance discovery with mood, astrology and personal scent identity.
</p>

<p align="center">
  The experience is built around three core spaces: <strong>Today</strong>, <strong>Discover</strong> and <strong>Profile</strong>.
</p>

## Overview

PerfumeSoul is designed as a soft, editorial-style perfume companion. Instead of showing fragrances as a plain catalog, the app frames scent through daily energy, personal taste and symbolic profile data.

The current version already includes the main navigation shell, custom SwiftUI screens, reusable module builders, presenter-driven navigation and a Core Data stack prepared for persistence.

## Product Direction

### Today
- Daily energy card inspired by astrological mood
- "Aroma of the Day" recommendation block
- Horizontal personalized perfume suggestions
- "On This Day in Perfumery" editorial section

### Discover
- Scent archetype entry point with quiz CTA
- Perfume comparison inputs for side-by-side exploration
- Similar scent discovery flow

### Profile
- Personal identity summary
- Natal chart-inspired fragrance profile
- Element balance block
- Additional profiles section for expanding the concept to multiple people

## Why It Feels Different

- Emotion-first perfume UX instead of a standard ecommerce layout
- Soft card-based interface with editorial spacing and premium visual rhythm
- Hybrid app structure: UIKit lifecycle + SwiftUI feature screens
- Clean feature boundaries through `Module`, `Presenter`, `Router` and `ViewModel`
- Persistence layer already initialized through Core Data

## Architecture

The project uses a hybrid composition:

- `UIKit` manages app launch, scene lifecycle and tab/navigation containers
- `SwiftUI` renders the feature interfaces
- Each feature is assembled through a dedicated module builder
- Navigation is delegated to routers
- Presentation actions are coordinated through presenters
- Screen state is stored in observable view models

### App Flow

```text
SceneDelegate
   |
   v
UITabBarController
   |
   +-- Today      -> UINavigationController -> TodayModule
   +-- Discover   -> UINavigationController -> DiscoverModule
   +-- Profile    -> UINavigationController -> ProfileModule
   +-- Settings   -> UINavigationController -> SettingsModule
```

## Project Structure

```text
PerfumeSoul/
├── Project.swift
├── PerfumeSoul/
│   ├── Classes/
│   │   ├── Application/
│   │   │   ├── AppDelegate.swift
│   │   │   └── SceneDelegate.swift
│   │   ├── Core/
│   │   │   └── CoreData/
│   │   │      ├── CoreDataManager.swift
│   │   │      └── PerfumeSoul.xcdatamodeld
│   │   └── Screens/
│   │      ├── TodayView/
│   │      ├── Discover/
│   │      ├── Profile/
│   │      ├── Settings/
│   │      └── MainTabViewController/
│   ├── Info.plist
│   └── Resources/
│      ├── Assets.xcassets
│      └── Base.lproj/
├── PerfumeSoulTests/
└── PerfumeSoulUITests/
```

## Technical Stack

- Language: Swift
- UI: SwiftUI with UIKit integration
- State management: Observation / `@Observable` / `@Bindable`
- Navigation: `UINavigationController` + router-based transitions
- Persistence: Core Data
- Project configuration: Tuist (`Project.swift`)
- Testing: unit test and UI test targets included
- Minimum iOS version: 18.6

## Implementation Notes

- `SceneDelegate` initializes the Core Data container and assembles the root tab bar
- Every main tab is created through its own module builder
- `TodayScreen`, `DiscoverScreen` and `ProfileScreen` already contain custom composed UI
- Some secondary flows such as quiz/details/settings are currently scaffolded as separate modules and ready for expansion

## Getting Started

### Prerequisites

- Xcode 16+
- Tuist installed locally
- iOS 18.6+ simulator or device

### Run Locally

1. Generate the project:

```bash
tuist generate
```

2. Open the generated project or workspace in Xcode.

3. Build and run the `PerfumeSoul` target.

## Current Status

PerfumeSoul already has a strong visual foundation and navigation structure for an editorial perfume app. The home tabs are designed, wired and ready to evolve into richer product flows such as quiz logic, fragrance comparison results, profile persistence and personalized recommendations.

## Preview

The current UI direction is centered around:

- light premium cards
- soft pink accents
- airy spacing
- fragrance discovery through personality and mood

This makes the project a strong base for a distinctive lifestyle app rather than a generic perfume catalog.
