# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the VGR (Västra Götalandsregionen) Design System for iOS - a Swift Package providing reusable, Figma-compatible UI components for iOS apps. All components are prefixed with `VGR` to avoid conflicts with SwiftUI and third-party frameworks.

**Language**: Swedish is used throughout the codebase (comments, localizations, README). Component names use English with VGR prefix.

**Target Platform**: iOS 18+ (see Package.swift platforms declaration)

## Build & Development Commands

### Building the Package
```bash
swift build
```

### Running Tests
```bash
swift test
```

### Building with Xcode
Since this is a Swift Package, it's typically developed by adding it as a local package dependency to an Xcode project:
1. Clone this repository
2. In your app project: File > Add Package Dependencies > Add Local Package
3. Point to the `designsystem-ios` directory
4. Make changes and test directly in your app

## Code Architecture

### Directory Structure

```
Sources/DesignSystem/
├── Assets/              # Asset catalogs, localization files (sv.lproj)
├── Extensions/          # Swift extensions (Color, Font, View, etc.)
├── Gestures/            # Custom gesture recognizers (SwipeGesture)
├── Logic/               # Business logic and utilities
│   ├── Accessibility/   # Accessibility helpers
│   ├── Matomo/         # Analytics tracking (Tracker, TrackerViewModifier)
│   └── Haptics.swift
├── Services/            # Shared services (VGRVideoStatusService)
└── Views/              # UI components organized by type
    ├── Buttons/        # VGRButton, VGRStepper, VGRToggle, etc.
    ├── Cards/          # VGRCallout, VGRCalloutV2, VGRCardView, VGRVideoCarousel
    ├── Design/         # Design primitives (VGRIcon, VGRShape, VGRBlob, VGRDivider)
    ├── Inputs/         # Input components
    ├── Layouts/        # Layout components (VGRPortraitLandscapeView)
    ├── Pickers/        # Various picker components (Calendar, Body, Segmented, etc.)
    ├── Screens/        # Full-screen views (VGRContentScreen, VGRVideoPlayerView)
    ├── Sliders/        # Slider components (LevelSlider)
    └── WebSurvey/      # Survey components with Lottie animations
```

### Key Architectural Patterns

**Component Naming Convention**: All public components MUST use the `VGR` prefix. Internal utilities may omit the prefix if they're not exposed.

**Localization**: Strings use `.localizedBundle` extension (see String+Extensions.swift). All localized strings are in `Assets/sv.lproj/Localizable.strings`.

**Previews**: Components should have `#Preview` blocks for testing in Xcode. These are essential for component development.

**Analytics**: The design system includes integrated Matomo analytics via the `Tracker` class:
- Configuration via Info.plist keys: `MATOMO_SITE_ID` and `MATOMO_URL`
- Tracking is disabled in simulators (logs to console instead)
- Uses `TrackerViewModifier` for automatic screen tracking
- Apps must implement `TrackableScreen` protocol for type-safe tracking

**Video Functionality**:
- `VGRVideoStatusService`: Observable service tracking video watch states (notWatched, partiallyWatched, completed)
- Uses UserDefaults for persistence with app bundle ID as key prefix
- `VGRVideoPlayerView`: Full-featured video player with Swedish subtitle selection, 85% completion tracking, accessibility announcements
- Video components: `VGRVideoCard`, `VGRVideoCarousel` for displaying video content

**Content System**: `VGRContent` and `VGRContentElement` models represent structured article/content with various element types (heading, text, image, video, links, lists). `VGRContentScreen` renders these dynamically.

**State Management**: Uses SwiftUI's `@Observable` macro (iOS 18+) for services like `VGRVideoStatusService`.

## Dependencies

The package depends on:
- **MatomoTracker** (7.5.0+): Analytics tracking
- **Lottie** (4.5.0+): Animation support (used in VGRBlob, survey components)
- **SwiftUIIntrospect** (26.0.0+): UIKit introspection for SwiftUI

## Versioning & Release Process

**Automated Versioning**: The repository uses automated semantic versioning via GitHub Actions:
- On push to `main`, `versioning.sh` runs automatically
- Files added/removed → Minor version bump (e.g., 0.1.0 → 0.2.0)
- Files modified → Patch version bump (e.g., 0.1.0 → 0.1.1)
- Updates `VERSION` file and `Sources/DesignSystem/LibraryInfo.swift`
- Creates git tag and commits with `[CI]` suffix

**Manual Versioning**: Run `./versioning.sh` locally if needed, but this is typically handled by CI.

**LibraryInfo**: Apps can check the design system version via `LibraryInfo.version`.

## Development Guidelines

**When adding new components**:
1. Use `VGR` prefix for all public types
2. Place in appropriate `Views/` subdirectory
3. Add `#Preview` block for visual testing
4. Consider accessibility (VoiceOver labels, focus states)
5. Use existing design tokens (colors, fonts) from Extensions

**Accessibility Considerations**:
- Use `AccessibilityHelpers` for common patterns
- Provide meaningful `.accessibilityLabel()` and `.accessibilityValue()`
- Test with VoiceOver
- See `VGRVideoPlayerView` for example of `@AccessibilityFocusState` usage

**Testing in Apps**: The design system is tested by adding it as a local Swift Package to consumer apps. There's a test suite in `DesignSystem-Tests` target, but most validation happens via integration testing in real apps.

**Colors & Fonts**: Use extensions in `Color+Extensions.swift` and `Font+Extensions.swift` rather than hardcoded values. These provide design token access (e.g., `Color.Elevation.background`, `Font.bodyRegular`).

## Common Patterns

**View Modifiers**: The package provides custom modifiers like:
- `vgrTimePickerPopover`: Time picker in popover
- Matomo tracking modifiers (see `TrackerViewModifier.swift`)

**Conditional iOS Version Handling**: See `VGRDoneButton` for example of iOS 26+ feature with fallback.

**Lottie Animations**: Use `VGRLottieView` wrapper (in WebSurvey/) rather than importing Lottie directly.

**Calendar Components**: Complex calendar system with `VGRCalendarView`, `VGRCalendarViewModel`, `VGRCalendarPeriodModel`, and `VGRCalendarIndexKey`. The calendar uses a custom cell rendering system via generics.

**Body Picker**: Medical application body part selection via `VGRBodyPickerView` with anatomical data models in `VGRBodyPartData`.
