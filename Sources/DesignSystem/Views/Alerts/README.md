# VGRAlert

A lightweight wrapper around `UIAlertController` that keeps alert definitions close to the logic that triggers them. The UIKit backing means the alert renders with the iOS 26 HIG anatomy — including the blue primary capsule for `.confirm(...)` buttons.

## Setup

Add a `VGRAlert?` property to your viewmodel:

```swift
@Observable
class MyViewModel {
    var alert: VGRAlert? = nil
}
```

Attach the modifier once in your view:

```swift
.vgrAlert(item: $viewModel.alert)
```

## Triggering alerts

### Common patterns

Factory methods cover the most frequent cases. Titles and messages have localized defaults but can be overridden.

```swift
// Unsaved changes
alert = .unsavedChanges { dismiss() }

// Delete confirmation
alert = .confirmDelete(name: "Ibuprofen") { performDelete() }

// Error
alert = .error(someError)
```

Override defaults when needed:

```swift
alert = .unsavedChanges(
    title: "Du har osparade ändringar",
    message: "Vill du verkligen lämna sidan?"
) {
    dismiss()
}
```

### Custom alerts

Build any alert inline. Actions are embedded directly, so the view never needs to know what kind of alert is being shown.

```swift
alert = VGRAlert(
    title: "Ändra schema?",
    message: "Detta påverkar alla doser.",
    buttons: [
        .confirm("Ändra") { performSave() },
        .cancel()
    ]
)
```

### Viewmodel-driven alerts with view actions

When the viewmodel decides which alert to show but the action (e.g. `dismiss()`) lives in the view, pass it as a closure:

```swift
// ViewModel
@Observable
class MyViewModel {
    var alert: VGRAlert? = nil

    func save(onDiscard: @escaping () -> Void) {
        guard hasUnsavedChanges else { return }
        alert = .unsavedChanges(onDiscard: onDiscard)
    }
}

// View
Button("Spara") {
    viewModel.save(onDiscard: { dismiss() })
}
.vgrAlert(item: $viewModel.alert)
```

This keeps navigation logic in the view while letting the viewmodel control when and which alert appears.

## Buttons

Factory methods on `VGRAlertButton`:

```swift
.default("OK") { handleOK() }            // Standard button
.confirm("Spara") { save() }             // Preferred action — blue capsule on iOS 26
.destructive("Ta bort") { delete() }     // Destructive (red) button
.close("Stäng") { dismiss() }            // iOS 26 close role, falls back to cancel
.cancel()                                // Cancel button, defaults to localized "Avbryt"
.cancel("Stäng")                         // Cancel button with custom label
```

Use `.confirm(...)` to mark the preferred action. On iOS 26 it renders as the blue primary capsule from the HIG anatomy; on earlier iOS it gets the bold "preferred" treatment.

## Implementation notes

The `.vgrAlert(item:)` modifier is backed by `UIAlertController` (presented through a `UIViewControllerRepresentable`) rather than SwiftUI's `.alert(...)`. This is required to access `UIAlertController.preferredAction`, which is what triggers the blue primary capsule on iOS 26 — SwiftUI's alert API does not expose this.

## Files

| File | Purpose |
|---|---|
| `VGRAlert.swift` | `VGRAlert` and `VGRAlertButton` types |
| `VGRAlert+Common.swift` | Factory methods: `unsavedChanges`, `confirmDelete`, `error` |
| `View+VGRAlert.swift` | `.vgrAlert(item:)` view modifier (UIKit-backed) |
| `VGRAlertExample.swift` | Preview with usage examples |
