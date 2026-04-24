# Notifications

Unified local-notification layer. Replaces the per-app `NotificationHelper` singletons in dermatology and migraine, and brings epilepsy onto the same footing.

## What's in the module

| File | Role |
|---|---|
| `NotificationManager` | `actor` facade — the one type your app talks to |
| `NotificationSettings` | Per-context config (enabled, content, time, recurrence, deviations, window cursor) |
| `NotificationContent` | Sendable payload model: title, body, sound, interruption level, category, userInfo, badge |
| `NotificationRequest` / `NotificationTrigger` | Scheduler-level value types; bridged to `UN*` at the edge |
| `NotificationScheduling` | Protocol + `SystemNotificationScheduler` (wraps `UNUserNotificationCenter`) |
| `NotificationStoring` | Protocol + `UserDefaultsNotificationStore` + `InMemoryNotificationStore` |
| `NotificationAuthorizing` | Protocol + `SystemNotificationAuthorizer` + `PreviewNotificationAuthorizer` |
| `NotificationBackgroundRefresher` | `BGAppRefreshTask` glue for the rolling window |
| `EnvironmentValues.notifications` | Built-in SwiftUI environment accessor — `@Environment(\.notifications)` |

## Core model

**One `contextId` ↔ one `NotificationSettings`.** The `contextId` is yours — usually a dotted, domain-qualified string (`"reminders"`, `"medication.schema.<uuid>.slot.<uuid>"`). The manager derives zero or more `UNNotificationRequest`s from the settings, using identifiers of the form `"<contextId>_<n>"` or `"<contextId>_repeat"`.

### Two scheduling modes

The manager picks automatically based on the settings:

- **Native repeating trigger** — one `UNCalendarNotificationTrigger(repeats: true)`. Used when `recurrence.frequency == 1`, no deviations, no `endDate`, and (for weekly) at most one weekday. No background refresh needed.
- **Rolling window** — individual non-repeating triggers, pre-materialized for the next `windowDays` (default 60). Used for everything else. The background refresher extends the window as it drains.

---

## Setup

The manager is an `actor`, constructed once and held for the whole lifetime of the app. Everything in this section lives in the **app target**, not in this package.

There are two hosts you'll touch:

| Where | What it holds |
|---|---|
| `@main App` struct (`YourApp.swift`) | Owns the `NotificationManager` and `NotificationBackgroundRefresher` as stored properties, registers the refresher in `init()`, drives `scenePhase` transitions, and injects the manager into the environment |
| `UIApplicationDelegateAdaptor` class | Owns `UNUserNotificationCenter.delegate` for foreground presentation and tap handling |

The SwiftUI environment accessor (`@Environment(\.notifications)`) is provided by the design system — apps don't define it.

### 1. `@main App` — the canonical host

```swift
// YourApp.swift — app target
import SwiftUI
import DesignSystem

@main
struct YourApp: App {

    // Constructed once in init(), held for the app's lifetime.
    private let notifications: NotificationManager

    // Held so the BGTaskScheduler handler closure keeps a live reference.
    // Loses its effect if you let it go out of scope.
    private let refresher: NotificationBackgroundRefresher

    // Owns UNUserNotificationCenter.delegate — see step 2.
    @UIApplicationDelegateAdaptor(NotificationDelegateAdapter.self)
    private var appDelegate

    @Environment(\.scenePhase) private var scenePhase

    init() {
        let manager = NotificationManager.live()
        let refresher = NotificationBackgroundRefresher(
            manager: manager,
            taskIdentifier: "com.example.app.notifications.refresh"
        )
        // Must run before the first scene connects — see "Background refresh".
        refresher.register()

        self.notifications = manager
        self.refresher = refresher
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.notifications, notifications)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background {
                refresher.scheduleNext()
            }
        }
    }
}
```

For app-group `UserDefaults`, swap the factory call in `init()`:

```swift
let shared = UserDefaults(suiteName: "group.com.example.app")!
let manager = NotificationManager.live(suite: shared)
```

Custom configuration (window size, per-context cap, refresh lead time):

```swift
let manager = NotificationManager.live(
    configuration: .init(windowDays: 30, maxIndividualRequests: 30)
)
```

### 2. `UIApplicationDelegateAdaptor` — foreground presentation + taps

The manager deliberately never assigns **UNUserNotificationCenter.current().delegate**. 
Assigning it is the app's job — delegate callbacks (willPresent, didReceive) drive app-specific UX and routing decisions that don't belong in the design system.

```swift
// NotificationDelegateAdapter.swift — in your app
import UIKit
import UserNotifications

final class NotificationDelegateAdapter: NSObject,
                                         UIApplicationDelegate,
                                         UNUserNotificationCenterDelegate {

    // Called by UIKit at launch, before the scene connects.
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // Fires when a notification arrives while the app is in foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent _: UNNotification,
                                withCompletionHandler completion: @escaping (UNNotificationPresentationOptions) -> Void) {
        completion([.banner, .sound, .badge, .list])
    }

    // Fires when the user taps a notification — from any app state.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completion: @escaping () -> Void) {
        let contextId = response.notification.request.content.userInfo["context_id"] as? String
        // Route the tap using contextId — e.g. post to your deep-link router.
        completion()
    }
}
```

The manager injects `context_id` and `scheduled_at` into every scheduled notification's `userInfo`, so `didReceive` can always identify which schedule fired.

### 3. Reading the manager from a view

The design system ships `@Environment(\.notifications)` — nothing to define in the app target:

```swift
// RemindersSettingsView.swift — app target
import SwiftUI
import DesignSystem

struct RemindersSettingsView: View {
    @Environment(\.notifications) private var notifications
    // ... see "Scheduling recipes" below for what goes in the body
}
```

The value is `NotificationManager?` — `nil` when nothing has been injected (e.g. previews). The injection happens on the root scene in `YourApp` above: `.environment(\.notifications, notifications)`.

Apps that prefer a different DI pattern (an `AppState` observable, a dependency container, etc.) can ignore the environment accessor and pass the manager however they like — the manager's API is identical regardless of how it's reached.

### Register categories (optional, for actionable notifications)

Call once, from a root view's `.task { }` — init is synchronous and can't await:

```swift
// RootView.swift — app target
struct RootView: View {
    @Environment(\.notifications) private var notifications

    var body: some View {
        TabView { /* … */ }
            .task {
                await notifications?.register(categories: [
                    UNNotificationCategory(
                        identifier: "medication.reminder",
                        actions: [UNNotificationAction(identifier: "taken", title: "Taken", options: [])],
                        intentIdentifiers: []
                    )
                ])
            }
    }
}
```

Then set `content.categoryIdentifier = "medication.reminder"` on any `NotificationSettings` that should surface those actions.

---

## Authorization

Call `requestAuthorization` from a **user-initiated action** — an onboarding button, a settings Toggle handler. iOS only prompts once per install, so the first call must be deliberate; don't call it from app launch or a view's `.task {}`.

```swift
// OnboardingNotificationsStep.swift — app target
struct OnboardingNotificationsStep: View {
    @Environment(\.notifications) private var notifications
    @State private var isProcessing = false

    var body: some View {
        Button("Enable reminders") {
            Task {
                isProcessing = true
                defer { isProcessing = false }
                guard let notifications,
                      try await notifications.requestAuthorization() else { return }
                // Now schedule — see "Scheduling recipes".
            }
        }
        .disabled(isProcessing)
    }
}
```

To render the current permission state (authorized / denied / not-determined), read it from `.task { }` on the settings screen that shows the toggle:

```swift
// RemindersSettingsView.swift — app target
struct RemindersSettingsView: View {
    @Environment(\.notifications) private var notifications
    @State private var status: UNAuthorizationStatus = .notDetermined

    var body: some View {
        Form { /* toggles, time picker, etc. */ }
            .task {
                status = await notifications?.authorizationStatus() ?? .notDetermined
            }
    }
}
```

Pass explicit options if you want `.timeSensitive`, `.criticalAlert`, etc. — still from a user action:

```swift
_ = try await notifications.requestAuthorization(options: [.alert, .badge, .sound, .timeSensitive])
```

---

## Global on/off switch

Separate from the OS-level permission (`authorizationStatus()`), the manager owns an **app-level** master switch. This is the toggle typically exposed under *Settings → Notifications → Enabled* in the app's own UI.

| State | Effect |
|---|---|
| `true` *(default)* | All per-context settings behave as written |
| `false` | Every pending request is cleared; new `update` / `activate` calls still persist settings but skip scheduling; `refreshSchedules()` is a no-op |

Flipping the switch back to `true` re-materializes every stored context whose `enabled == true` — so users don't lose their per-reminder configuration when they toggle the master off and on.

### Read & write

```swift
// GlobalNotificationsToggle.swift — app target
struct GlobalNotificationsToggle: View {
    @Environment(\.notifications) private var notifications
    @State private var isOn = true

    var body: some View {
        Toggle("Enable notifications", isOn: $isOn)
            .task {
                isOn = await notifications?.isGlobalEnabled() ?? true
            }
            .onChange(of: isOn) { _, newValue in
                Task {
                    try await notifications?.setGlobalEnabled(newValue)
                }
            }
    }
}
```

### When to use this vs. `deactivate(contextId)`

- Use **`setGlobalEnabled(false)`** for the app-wide *"turn everything off"* toggle in settings.
- Use **`deactivate(contextId)`** when a specific schedule should stop — e.g. a user toggles off a single reminder while leaving the rest alone.

### Relationship with OS-level authorization

These two gates are independent:

| OS authorization | App global switch | Notifications fire? |
|---|---|---|
| granted | on | ✅ |
| granted | off | ❌ (app suppresses) |
| denied | on | ❌ (OS refuses scheduling) |
| denied | off | ❌ |

The app-level switch is useful even when OS permission is granted — some users want to keep permission active (so other notifications they care about still arrive) but silence your specific app.

---

## Scheduling recipes

All APIs below are `async`, so each call runs inside a `Task { }`. The typical call site is a SwiftUI action closure — a `Button` action, a `Toggle`'s `.onChange`, or a form's `Save` handler — on the settings screen that the user is editing. Every recipe assumes `notifications` is the injected `NotificationManager`:

```swift
// The shape all recipes below fit into:
Toggle("Reminders", isOn: $enabled)
    .onChange(of: enabled) { _, isOn in
        Task {
            guard let notifications else { return }
            if isOn {
                try await notifications.update("reminders", settings: makeSettings())
            } else {
                try await notifications.deactivate("reminders")
            }
        }
    }
```

For readability, the recipes that follow show only the body of the `Task { }` — wrap them in the closure of whichever control is driving the change.

### Daily at 8:00 (cheapest possible — native repeat)

```swift
let settings = NotificationSettings(
    content: .init(title: "reminder.title", body: "reminder.body"),
    timeOfDay: at(hour: 8, minute: 0),
    recurrence: Recurrence(frequency: 1, period: .day)
)
try await notifications.update("reminders", settings: settings)
```

Titles/bodies are passed through `NSString.localizedUserNotificationString(forKey:arguments:)` at render time, so localization keys work directly.

### Weekdays only

```swift
let settings = NotificationSettings(
    content: .init(title: "meds.title", body: "meds.body"),
    timeOfDay: morningTime,
    recurrence: Recurrence(frequency: 1, period: .week,
                           weekdays: [.monday, .tuesday, .wednesday, .thursday, .friday])
)
try await notifications.update("reminders", settings: settings)
```

Multi-weekday → rolling window.

### Every other day, for one month

```swift
let settings = NotificationSettings(
    content: .init(title: "Therapy", body: "Apply cream"),
    timeOfDay: eveningTime,
    startDate: .now,
    endDate: Calendar.current.date(byAdding: .month, value: 1, to: .now),
    recurrence: Recurrence(frequency: 2, period: .day)
)
try await notifications.update("therapy.cream", settings: settings)
```

### One-shot (no recurrence)

```swift
let settings = NotificationSettings(
    content: .init(title: "Appointment", body: "In 2 hours"),
    timeOfDay: fireAt,
    startDate: fireAt,
    recurrence: nil
)
try await notifications.update("appointment.\(id)", settings: settings)
```

### Skip or move a single occurrence

```swift
var settings = await notifications.settings(for: "reminders")!
settings.deviations = [
    RecurrenceDeviation(original: mondayDate, isHidden: true),         // skip
    RecurrenceDeviation(original: tuesdayDate, adjusted: newDate)      // move
]
try await notifications.update("reminders", settings: settings)
```

Adding any deviation forces the rolling-window path (can't be expressed as a native repeat).

### Medication-style fan-out

Create one context per slot, prefixed by a shared family ID so you can tear them all down together:

```swift
for slot in schema.slots {
    let id = "medication.schema.\(schema.id).slot.\(slot.id)"
    try await notifications.update(id, settings: settingsFor(slot))
}

// Later, when the schema is deleted:
await notifications.cleanup(contextIdPrefix: "medication.schema.\(schema.id).slot.")
```

### Activate / deactivate without losing config

```swift
try await notifications.deactivate("reminders")   // clears pending, keeps stored settings
try await notifications.activate("reminders")     // re-materializes from stored settings
```

### Read current settings

```swift
let settings = await notifications.settings(for: "reminders")
let all      = await notifications.allSettings()
```

---

## Background refresh

Required for any schedule that falls into the rolling-window path (deviations, `frequency > 1`, finite `endDate`, multi-weekday). For schedules that use the native repeating trigger, this section is optional — the OS handles everything.

The wiring is split across **three locations**, all in the app target. The `@main App` example in [Setup](#1-main-app--the-canonical-host) already shows all three — this section explains each piece.

### 1. Info.plist — `BGTaskSchedulerPermittedIdentifiers`

Add the identifier to your app target's `Info.plist`. Without this, `BGTaskScheduler.register` silently fails at launch.

```xml
<!-- YourApp/Info.plist -->
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.example.app.notifications.refresh</string>
</array>
```

The string must match the `taskIdentifier` passed to `NotificationBackgroundRefresher(taskIdentifier:)`. Use a reverse-DNS identifier scoped to this app target.

### 2. `@main App.init()` — register the handler

`refresher.register()` must be called **before the first scene connects**. The only place that guarantees this in a SwiftUI app is the `@main App` struct's `init()`. Calling it later (from a view's `.task`, from `scenePhase.active`, from an ad-hoc `AppDelegate` method that runs after the first scene) will log a failed registration and the handler will never fire.

```swift
// YourApp.swift — inside the @main App init(), as shown in Setup
init() {
    let manager = NotificationManager.live()
    let refresher = NotificationBackgroundRefresher(
        manager: manager,
        taskIdentifier: "com.example.app.notifications.refresh"
    )
    refresher.register()     // ← THIS line, here, before properties are assigned

    self.notifications = manager
    self.refresher = refresher
}
```

Keep `refresher` as a stored `let` on the `App` struct. If you let it go out of scope, the closure `BGTaskScheduler` is holding stays live but the `NotificationManager` reference inside it may not behave as expected on the next wake.

### 3. `@main App.body` — submit the next refresh on background

Submitting a `BGAppRefreshTaskRequest` tells the OS "wake me in ~N seconds to run the registered handler." The handler re-submits itself on every wake, so you only need to seed this loop once per app lifecycle — the canonical place is the `scenePhase` transition to `.background` on the `@main App`'s `Scene` body.

```swift
// YourApp.swift — inside var body: some Scene, as shown in Setup
.onChange(of: scenePhase) { _, phase in
    if phase == .background {
        refresher.scheduleNext()
    }
}
```

Default cadence is 7 days (`NotificationBackgroundRefresher(refreshInterval:)` takes an override). The OS may delay the actual wake based on device conditions — it's a floor, not a schedule.

### What each call does, in one sentence

| Call | Where | When | Effect |
|---|---|---|---|
| `refresher.register()` | `@main App.init()` | Every app launch, before scene connects | Tells `BGTaskScheduler` which handler runs for this identifier |
| `refresher.scheduleNext()` | `@main App.body` → `scenePhase == .background` | Each time the app is backgrounded | Submits the next `BGAppRefreshTaskRequest` |
| `manager.refreshSchedules()` | Inside the handler (called by `refresher`) | When the OS wakes the app | Iterates stored settings and extends rolling windows |

### Foreground top-up (optional)

As belt-and-braces, call `refreshSchedules()` directly when the app is backgrounded — doesn't hurt, and keeps schedules fresh even if the OS never grants the BG task wake:

```swift
// YourApp.swift — inside .onChange(of: scenePhase), alongside scheduleNext()
.onChange(of: scenePhase) { _, phase in
    if phase == .background {
        refresher.scheduleNext()
        Task { try await notifications.refreshSchedules() }
    }
}
```

### UIKit alternative

If your app is UIKit-first (no `@main App` struct), call `refresher.register()` from `application(_:didFinishLaunchingWithOptions:)` in your `UIApplicationDelegate`, and `refresher.scheduleNext()` from `applicationDidEnterBackground(_:)`. The `NotificationBackgroundRefresher` instance must still be held as a stored property — on the `AppDelegate` in this case.

---

## Previews

For SwiftUI `#Preview` blocks, the package ships a one-liner that injects an in-memory manager backed by `RecordingNotificationScheduler` + `InMemoryNotificationStore` + `PreviewNotificationAuthorizer`. Nothing touches `UNUserNotificationCenter`, `UserDefaults`, or `BGTaskScheduler`.

### Simplest case

```swift
#Preview {
    RemindersSettingsView()
        .previewNotifications()
}
```

Every view downstream of `.previewNotifications()` resolves `@Environment(\.notifications)` to a working manager. Calls to `update`, `activate`, `deactivate`, `settings(for:)`, etc. all succeed silently — the preview just won't post real system notifications.

### Pre-seeded state

Seed existing settings so the view renders populated state:

```swift
#Preview("With existing reminder") {
    RemindersSettingsView()
        .previewNotifications(settings: [
            "reminders": .preview
        ])
}
```

`NotificationSettings.preview` is a daily-at-08:00 sample bundled for convenience. Build your own for richer states.

### Denied authorization state

```swift
#Preview("Permission denied") {
    RemindersSettingsView()
        .previewNotifications(granted: false)
}
```

`manager.requestAuthorization()` returns `false`, `authorizationStatus()` returns `.denied` — lets you preview the "permission denied" UI path.

### Inspecting what the view scheduled

For snapshot-style previews or development-time debugging, build the manager yourself and hold it, so you can peek at the recording scheduler:

```swift
#Preview("Inspector") {
    let scheduler = RecordingNotificationScheduler()
    let manager = NotificationManager(
        scheduler: scheduler,
        store: InMemoryNotificationStore(),
        authorizer: PreviewNotificationAuthorizer(granted: true)
    )
    return VStack {
        RemindersSettingsView()
        AsyncView { await scheduler.scheduled.count }
            .font(.caption)
    }
    .environment(\.notifications, manager)
}
```

> `manager.notificationSettings()` traps on the preview manager — `UNNotificationSettings` has no public initializer. Preview-safe code should use `authorizationStatus()` only.

---

## Testing

Use `NotificationManager.preview(...)` for unit tests too, or compose the stubs directly:

```swift
let scheduler = RecordingNotificationScheduler()
let store     = InMemoryNotificationStore()
let manager   = NotificationManager(
    scheduler: scheduler,
    store: store,
    authorizer: PreviewNotificationAuthorizer(granted: true)
)

try await manager.update("reminders", settings: .preview)
let pending = await scheduler.scheduled
#expect(pending.count == 1)
#expect(pending.first?.identifier.hasPrefix("reminders_") == true)
```

Shipped test doubles:

| Type | Role |
|---|---|
| `RecordingNotificationScheduler` | Records `schedule` / `remove` calls for assertions |
| `InMemoryNotificationStore` | Holds the settings map in memory, seedable via `init(initial:)` |
| `PreviewNotificationAuthorizer` | Returns a fixed authorization result; `.notificationSettings()` traps |

> Use `SystemNotificationAuthorizer` in any test path that actually needs a real `UNNotificationSettings` value — e.g. integration tests that exercise the full permission pipeline.

---

## Migrating from `NotificationHelper`

### API mapping

| Old (`NotificationHelper.shared`) | New (`NotificationManager`) |
|---|---|
| `requestPermissions(completion:)` | `requestAuthorization()` (async throws) |
| `activateNotifications(id)` | `activate(id)` (async throws) |
| `disableNotifications(id)` | `deactivate(id)` (async throws) |
| `deleteNotifications(id)` | `delete(id)` |
| `getSettings(for:)` | `settings(for:)` |
| `updateSettings(id, isActive:timeOfDay:recurrence:…)` | `update(id, settings:)` — build full `NotificationSettings` |
| `getNotificationSettingsSync()` | `notificationSettings()` (async, no semaphore) |
| `cleanupNotificationsByPrefix(prefix)` | `cleanup(contextIdPrefix: prefix)` |
| `performBackgroundScheduling()` | `refreshSchedules()` via `NotificationBackgroundRefresher` |
| `hasNotificationsForContext(id)` | `hasSettings(for: id)` |

### Key behavioral changes

- **No singleton.** Hold an instance (e.g. on your `AppState` / environment object).
- **No callbacks.** All async APIs are `async` / `async throws`.
- **Fresh persistence.** The new store uses `"designsystem.notifications.v1"` under `UserDefaults.standard` by default. Existing schedules written by the old helper are not read; re-save on next user interaction (or seed explicitly during your migration).
- **Multi-weekday weekly recurrence is no longer silently truncated.** The old helper took `weekdays.first` and dropped the rest; the new manager schedules each weekday individually via the rolling window.
- **Content is part of the settings.** Title and body live on `NotificationContent` inside `NotificationSettings`. No separate `.title` / `.body` parameters on the update call.
- **Delegate stays in your app.** Nothing in the DS module binds `UNUserNotificationCenter.delegate`.

### Before / after (dermatology)

```swift
// Before
NotificationHelper.shared.requestPermissions { granted, _ in
    guard granted else { return }
    NotificationHelper.shared.updateSettings(
        "reminders",
        isActive: true,
        timeOfDay: time,
        recurrence: Recurrence(frequency: 1, period: .week, weekdays: [.monday])
    )
}

// After
let granted = try await notifications.requestAuthorization()
guard granted else { return }

let current = await notifications.settings(for: "reminders") ?? NotificationSettings(
    content: .init(title: "reminder.title", body: "reminder.body"),
    timeOfDay: time
)
var updated = current
updated.enabled = true
updated.timeOfDay = time
updated.recurrence = Recurrence(frequency: 1, period: .week, weekdays: [.monday])
try await notifications.update("reminders", settings: updated)
```
