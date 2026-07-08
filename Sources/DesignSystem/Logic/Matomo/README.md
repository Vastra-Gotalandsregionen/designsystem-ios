# Matomo Tracker

A thin wrapper around `MatomoTracker`, exposed as the `Tracker.shared` singleton. Two things to know up front:

- Nothing is sent unless the user is **opted in** (see [Consent](#consent)).
- In the **simulator** nothing is sent — calls are logged to the console instead.

## Setup

`Tracker.shared` configures itself from the app's `Info.plist`. Add these keys (values are typically injected from an `.xcconfig`):

| Key | Required | Description |
|-----|----------|-------------|
| `MATOMO_SITE_ID` | ✅ | The site ID in Matomo. |
| `MATOMO_URL` | ✅ | Full URL to the Matomo endpoint, e.g. `https://example.org/matomo.php`. |
| `MATOMO_APPVERSION_DIMENSION` | – | Index of a **Visit-scope** custom dimension that receives `CFBundleShortVersionString`. Create the dimension in the Matomo backend first, then set its index here. |

```xml
<key>MATOMO_SITE_ID</key>
<string>$(MATOMO_SITE_ID)</string>
<key>MATOMO_URL</key>
<string>https://$(MATOMO_URL)</string>
<key>MATOMO_APPVERSION_DIMENSION</key>
<string>$(MATOMO_APPVERSION_DIMENSION)</string>
```

No manual init call is needed. On device, missing site ID / URL is a fatal misconfiguration.

## Tracking views

A **view** records *where* the user is. Model your screens as a `TrackableScreen`:

> **Note:** Define **one `TrackableScreen` enum per app**, holding every screen as a case. It's the app's single, central catalogue of trackable screens.

```swift
enum AppScreen: TrackableScreen {
    case home
    case headache(action: TrackerAction)   // TrackerAction is built in

    var identifier: String {
        switch self {
            case .home: return "home"
            case .headache(let action): return "\(action.rawValue)_headache"
        }
    }
}
```

Track on appear with the view modifier (preferred in SwiftUI):

```swift
SomeView()
    .track(AppScreen.home)
```

…or call the tracker directly:

```swift
Tracker.shared.trackScreen(AppScreen.headache(action: .create))
Tracker.shared.trackScreen(AppScreen.home, note: "from_deeplink")   // optional note
Tracker.shared.trackOnceDaily(AppScreen.home)                        // at most once per calendar day
```

Something *triggered* like an action but that you still want recorded as its own view (e.g. a delete logged as `delete_medication`, not an event) uses `trackEvent(_:note:)`:

```swift
Tracker.shared.trackEvent(AppScreen.medication(action: .delete))     // still a view
```

## Tracking events

An **event** records *what the user did within a screen*. Model interactions as a `TrackableInteraction` (each app owns its own vocabulary):

> **Note:** Define **one `TrackableInteraction` enum per feature** (e.g. one for headaches, one for medication), each holding that feature's interactions. Unlike screens, interactions are scoped per feature rather than collected app-wide.

```swift
enum HeadacheInteraction: TrackableInteraction {
    case addSymptom(String)   // name carries which symptom
    case setPainLevel(Int)    // value carries the number

    var action: String {
        switch self {
            case .addSymptom: return "add_symptom"
            case .setPainLevel: return "set_pain_level"
        }
    }
    var name: String? {
        switch self {
            case .addSymptom(let symptom): return symptom
            case .setPainLevel: return nil
        }
    }
    var value: Float? {
        switch self {
            case .setPainLevel(let level): return Float(level)
            default: return nil
        }
    }
}
```

Track it, passing the screen it happened on — **the screen supplies the event category**:

```swift
Tracker.shared.trackEvent(HeadacheInteraction.addSymptom("nausea"),
                          on: AppScreen.headache(action: .create))
// category=create_headache · action=add_symptom · name=nausea

Tracker.shared.trackEvent(HeadacheInteraction.setPainLevel(7),
                          on: AppScreen.headache(action: .create))
// category=create_headache · action=set_pain_level · value=7
```

## Consent

Nothing is tracked unless the user is opted in (defaults to opted-in on first launch):

```swift
Tracker.shared.setOptInSetting(false)   // opt out
Tracker.shared.setOptInSetting(true)    // opt in
Tracker.shared.isOptedIn                // current state
```
