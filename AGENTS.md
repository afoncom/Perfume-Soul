# Repository Guidelines

## Project Structure & Module Organization

PerfumeSoul is a Tuist-managed iOS app with a small Swift backend. `Project.swift` defines the app, unit test, and UI test targets. App code lives in `PerfumeSoul/Classes`: `Application` for lifecycle, `Core/CoreData` for persistence, `Services` for app services, and `Screens` for feature modules. Screen modules generally follow `Module`, `Presenter`, `Router`, `ViewModel`, and `Screen` files. Assets, storyboards, and localized strings are in `PerfumeSoul/Resources`. iOS tests are in `PerfumeSoulTests` and `PerfumeSoulUITests`; the Vapor backend is in `backend/PerfumeSoulBackend`.

## Build, Test, and Development Commands

- `tuist generate`: generate the Xcode project.
- `tuist build PerfumeSoul`: build the iOS app.
- `tuist test PerfumeSoulTests`: run unit tests.
- `tuist test PerfumeSoulUITests`: run UI tests.
- `swiftlint`: run `.swiftlint.yml` rules.
- `cd backend/PerfumeSoulBackend && swift test`: run backend tests.
- `cd backend/PerfumeSoulBackend && swift run PerfumeSoulBackend`: start Vapor locally.

## Coding Style & Naming Conventions

Use Swift with 4-space indentation. Follow SwiftLint: prefer `isEmpty`, `contains`, `first(where:)`, explicit control braces, no trailing semicolons, and `final` classes where possible. Keep SwiftUI observable properties private when lint requires it. Name feature files by feature and role, for example `TodayPresenter.swift` or `FindPerfumesViewModel.swift`. Keep generated resources and Core Data models under existing Tuist resource paths.

Use only colors from `PerfumeSoul/Resources/Assets.xcassets` through generated asset symbols. In SwiftUI, write `Color(.textPrimary)` or `Color(.backgroundPrimary)`; do not use shorthand `.textPrimary`, `Color.textPrimary`, or `Color("textPrimary")`. In UIKit, use `UIColor(resource: .backgroundPrimary)`. Never use system colors such as `Color.blue`, `UIColor.systemPink`, or `.secondarySystemBackground`. If a color is missing, add a colorset and use its generated symbol.

## Testing Guidelines

iOS tests use XCTest; backend tests use Swift Testing plus `VaporTesting`. Add tests near the target they cover and name methods with `test...` or descriptive backend `@Test` names. Prefer focused tests for presenters, services, loaders, and routes. Run the relevant Tuist test target for app changes and `swift test` for backend changes.

## Commit & Pull Request Guidelines

Recent commits use short imperative summaries, often title case, such as `Remove duplicate daily horoscope model`. Keep commits scoped to one behavior. Pull requests should include a summary, test commands, linked issue when applicable, and screenshots or recordings for UI changes.

## Agent-Specific Instructions

Do not revert unrelated local changes. Preserve the module/presenter/router structure when adding screens, use only generated asset color symbols in UI code, update localized strings in both `en.lproj` and `ru.lproj` when user-facing text changes, and keep backend fixture JSON under `Sources/PerfumeSoulBackend/Resources`.
