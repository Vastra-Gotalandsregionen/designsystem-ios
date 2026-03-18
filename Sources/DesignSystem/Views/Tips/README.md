# VGRInlineTipView

Inline tip component using Apple TipKit. Displays tips embedded in the content flow with VGR styling.

## Usage

```swift
import DesignSystem
import TipKit

struct MyView: View {
    private let tip = MyTip()

    var body: some View {
        VGRInlineTipView(
            tip: tip,
            smallCorner: .topLeading,
            onDismiss: {
                tip.invalidate(reason: .tipClosed)
            },
            onAppear: {
                // Optional: track impression
            }
        )
    }
}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `tip` | `Tip` | required | The TipKit tip to display |
| `smallCorner` | `VGRTipCorner` | `.none` | Corner to make small (for visual connection) |
| `backgroundColor` | `Color` | purple surface | Background color |
| `borderColor` | `Color` | purple | Border color |
| `foregroundColor` | `Color` | purple | Text and icon color |
| `onDismiss` | `(() -> Void)?` | `nil` | Called when X button tapped |
| `onAppear` | `(() -> Void)?` | `nil` | Called when tip appears |

## App Setup Required

To use tips in your app, you need to set up TipKit:

### 1. Configure TipKit at Launch

```swift
// In your App.swift or similar
Task {
    try? Tips.configure([
        .displayFrequency(.immediate)
    ])
}
```

### 2. Create Tips

```swift
struct SettingsTip: Tip {
    var title: Text { Text("Tips") }
    var message: Text? { Text("Check out settings for more options.") }
    var image: Image? { Image(systemName: "gearshape.fill") }
}
```

### 3. Optional: 31-Day Inactivity Pattern

To show tips only after user hasn't used a feature for 31 days:

```swift
struct SettingsTip: Tip {
    static let goalAchieved = Tips.Event(id: "settingsOpened")

    var rules: [Rule] {
        [
            #Rule(Self.goalAchieved) {
                $0.donations.donatedWithin(.days(31)).count == 0
            }
        ]
    }
}
```

**Key methods:**
- `donate()` - Record that an event happened (resets countdown)
- `invalidate(reason:)` - Hide tip permanently

## Corner Options

Use `VGRTipCorner` to create visual connection with adjacent UI:

```
.topLeading      .topTrailing
    ┌──────────────────┐
    │                  │
    │       TIP        │
    │                  │
    └──────────────────┘
.bottomLeading   .bottomTrailing
```

```swift
// Tip above content - small corner at bottom
VGRInlineTipView(tip: tip, smallCorner: .bottomTrailing)

// Tip below content - small corner at top
VGRInlineTipView(tip: tip, smallCorner: .topLeading)
```

## Custom Colors

```swift
VGRInlineTipView(
    tip: tip,
    backgroundColor: Color.Accent.greenSurfaceMinimal,
    borderColor: Color.Accent.green,
    foregroundColor: Color.Accent.green
)
```
