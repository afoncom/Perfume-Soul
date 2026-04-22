# Repository Guidelines

## Project Structure & Module Organization

PerfumeSoul is a Tuist-managed iOS app with a small Swift backend. `Project.swift` defines the iOS app, unit test, and UI test targets. App code lives in `PerfumeSoul/Classes`: `Application` contains lifecycle setup, `Core/CoreData` contains persistence, `Services` contains app services, and `Screens` contains feature modules. Each screen module generally follows `Module`, `Presenter`, `Router`, `ViewModel`, and `Screen` files. Assets, storyboards, and localized strings are in `PerfumeSoul/Resources`. iOS tests are in `PerfumeSoulTests` and `PerfumeSoulUITests`. The Vapor backend is in `backend/PerfumeSoulBackend`.

## Build, Test, and Development Commands

- `tuist generate`: generate the Xcode project from `Project.swift`.
- `tuist build PerfumeSoul`: build the iOS app target.
- `tuist test PerfumeSoulTests`: run the iOS unit tests.
- `tuist test PerfumeSoulUITests`: run the UI tests on a configured simulator.
- `swiftlint`: run SwiftLint using `.swiftlint.yml`.
- `cd backend/PerfumeSoulBackend && swift test`: run backend tests.
- `cd backend/PerfumeSoulBackend && swift run PerfumeSoulBackend`: start the Vapor backend locally.

## Coding Style & Naming Conventions

Use Swift with 4-space indentation. Follow the local SwiftLint rules: prefer `isEmpty`, `contains`, `first(where:)`, explicit control braces, no trailing semicolons, and `final` classes where possible. Keep SwiftUI observable properties private when lint requires it. Name feature files after the feature and role, for example `TodayPresenter.swift` or `FindPerfumesViewModel.swift`. Keep generated resources and Core Data models under the existing resource paths so Tuist includes them.

Use only named colors from `PerfumeSoul/Resources/Assets.xcassets`. Do not introduce direct system colors such as `Color.blue`, `Color.gray`, `UIColor.systemPink`, or `.secondarySystemBackground`. If a required color does not exist, add a new colorset to assets and use that asset by name.

## Testing Guidelines

iOS tests use XCTest; backend tests use Swift Testing plus `VaporTesting`. Add unit tests near the target they cover and name methods with the `test...` XCTest convention or descriptive `@Test` names in the backend. Prefer focused tests for presenters, services, loaders, and route behavior. Run the relevant Tuist test target for app changes and `swift test` for backend changes.

## Commit & Pull Request Guidelines

Recent commits use short imperative summaries, often title case, such as `Remove duplicate daily horoscope model` or `Replace system colors with asset colors`. Keep commits scoped to one behavior or refactor. Pull requests should include a concise summary, test commands run, linked issue when applicable, and screenshots or screen recordings for visible UI changes.

## Agent-Specific Instructions

Do not revert unrelated local changes. Preserve the module/presenter/router structure when adding screens, avoid system colors in UI code, update localized strings in both `en.lproj` and `ru.lproj` when user-facing text changes, and keep backend fixture JSON under `Sources/PerfumeSoulBackend/Resources`.
