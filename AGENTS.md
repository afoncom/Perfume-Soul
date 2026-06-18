# Repository Guidelines

## Project Structure & Module Organization

PerfumeSoul is a Tuist-managed iOS app with a Vapor backend. `Project.swift` defines the app plus `PerfumeSoulTests` and `PerfumeSoulUITests`. App code is under `PerfumeSoul/Classes`: `Application` for lifecycle, `Core/CoreData` for persistence, `Services` for network and domain logic, and `Screens` for feature UI. Screen folders usually contain `Module`, `Presenter`, `Router`, `ViewModel`, and `Screen` files. Assets, storyboards, and localizations live in `PerfumeSoul/Resources`. Backend code lives in `backend/PerfumeSoulBackend`.

## Build, Test, and Development Commands

- `tuist generate` builds the Xcode project from `Project.swift`.
- `tuist build PerfumeSoul` compiles the iOS app.
- `tuist test PerfumeSoulTests` runs unit tests; `tuist test PerfumeSoulUITests` runs UI tests.
- `swiftlint` checks repository Swift style rules from `.swiftlint.yml`.
- `cd backend/PerfumeSoulBackend && swift test` runs backend tests.
- `cd backend/PerfumeSoulBackend && swift run PerfumeSoulBackend` starts the local Vapor server.

## Coding Style & Naming Conventions

Use Swift with 4-space indentation and keep SwiftLint clean. Prefer `isEmpty`, `contains`, `first(where:)`, explicit braces, and `final` classes when practical. Name files by feature and role, for example `TodayPresenter.swift` or `SearchPerfumeViewModel.swift`. Preserve the existing screen module structure instead of mixing patterns.

Use only generated asset symbols from `PerfumeSoul/Resources/Assets.xcassets`. In SwiftUI, use `Color(.textPrimary)` or `LinearGradient(colors: [Color(.buttonShine), Color(.pinkButton)], ...)`. In UIKit, use `UIColor(resource: .backgroundPrimary)`. Do not hardcode system or string-based colors.

## Testing Guidelines

iOS tests use XCTest; backend tests use Swift Testing with `VaporTesting`. Add focused tests near the target they cover and name them with `test...` or descriptive backend `@Test` cases. Run the relevant Tuist test target for app changes and `swift test` for backend work.

## Commit & Pull Request Guidelines

Recent commits use short imperative subjects, often title case, for example `Escape LIKE wildcards in perfume search`. Keep commits scoped to a single behavior. Pull requests should include a summary, the commands used for verification, linked issues when relevant, and screenshots for UI changes.

## Configuration & Contributor Notes

Do not revert unrelated local changes. When user-facing text changes, update both `PerfumeSoul/Resources/en.lproj` and `PerfumeSoul/Resources/ru.lproj`. Keep backend fixture JSON under `backend/PerfumeSoulBackend/Sources/PerfumeSoulBackend/Resources` and retain existing Tuist resource paths for Core Data models and app assets.
