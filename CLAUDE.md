# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

VGR Designsystem iOS is a Swift Package providing design system components, colors, and typography for iOS apps used by Västra Götalandsregionen. All components are prefixed with `VGR` to avoid naming conflicts.

## Key Commands

### Building and Testing
- **Build the package**: `swift build`
- **Run tests**: `swift test`
- **Run specific test**: `swift test --filter <TestName>`

### Versioning
- **Update version**: `./versioning.sh` (automatically runs on push to main via GitHub Actions)
- Version is stored in `VERSION` file and automatically synced to `Sources/DesignSystem/LibraryInfo.swift`
- Versioning is automated: patch version bumps for file modifications, minor version bumps for added/removed files

### Development Workflow
When developing components:
1. Clone repo and add as local Swift Package in your Xcode project
2. Create feature branch: `git checkout -b feat/your-feature-name`
3. Make changes and test locally
4. Add `#Preview` blocks for visual testing in Xcode
5. Create PR against `main` branch

## Architecture

### Directory Structure

**Sources/designsystem/** (note: lowercase 'd' in actual filesystem)
- **Views/** - UI components organized by category
  - `Buttons/` - VGRButton, VGRCloseButton, VGRDoneButton, VGRStepper, VGRToggle, VGRTableRowNavigationLink
  - `Cards/` - VGRCallout, VGRCalloutV2, VGRDisclosureGroup, VGRCard
  - `Pickers/` - VGRBodyPickerView, VGRCalendarView, VGRDatePickerPopover, VGRMultiPickerView, VGRRecurrencePickerView, VGRSegmentedPicker
  - `Design/` - VGRIcon, VGRShape, VGRTableRowDivider, Blob (Lottie animations)
  - `Screens/Content/` - VGRContentScreen and article/content system
  - `Layouts/` - VGRPortraitLandscapeView

- **Extensions/** - Swift extensions for Color, Font, Date, Calendar, String, View, Bundle

- **Logic/** - Business logic and utilities
  - `Matomo/` - Analytics tracking (Tracker, TrackerViewModifier, TrackerConstants)
  - `Accessibility/` - Accessibility helpers
  - `Haptics.swift` - Haptic feedback utilities (lightImpact, mediumImpact, heavyImpact, success, warning, error)
  - `SizePreferanceKey.swift` - SwiftUI preference key for size calculations

- **Assets/** - Asset catalog with Images, Colors, Icons, Animations (Lottie), localized strings (sv.lproj)

- **LibraryInfo.swift** - Auto-generated version info accessible via `LibraryInfo.version`

### Design System Concepts

**Color System** (`Color+Extensions.swift`)
- Organized into namespaces: `Color.Primary`, `Color.Elevation`, `Color.Accent`, `Color.Neutral`, `Color.Status`, `Color.Custom`, `Color.Components`
- All colors loaded from asset catalog using `.module` bundle
- Example: `Color.Primary.action`, `Color.Accent.green`, `Color.Status.errorSurface`

**Typography** (`Font+Extensions.swift`)
- Weight-based variants: `bodyRegular`, `bodyMedium`, `bodyBold`, `bodySemibold`
- Also provides: `footnoteRegular`, `footnoteSemibold`, `headlineSemibold`, `title3Semibold`, `title3Bold`

**Content System** (`Views/Screens/Content/`)
- `VGRContent` - Main content/article data model with elements array
- `VGRContentElement` - Individual content elements (headings, text, images, links, lists)
- `VGRContentScreen` - Complete article rendering view
- `VGRContentElementView` - Router that renders appropriate view for each element type
- Supports various content types: headings, text, images, internal/external links, link groups, lists

### Dependencies
- **MatomoTracker** (7.5.0+) - Analytics tracking
- **Lottie** (4.5.0+) - Animations for Blob component
- **SwiftUIIntrospect** (26.0.0+) - UIKit introspection for SwiftUI

### Platform Requirements
- iOS 18+
- Swift 6.0+
- Default localization: Swedish (sv)

## Important Notes

- Package name is `DesignSystem` but filesystem uses lowercase `designsystem/` directory
- All public components must use `VGR` prefix
- Components should include `#Preview` blocks for Xcode canvas testing
- Version bumping is automated via GitHub Actions on push to main
- Use `.module` bundle when loading resources from asset catalog
