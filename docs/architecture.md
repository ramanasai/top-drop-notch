# Architecture

**Stack decision:** [ADR-0001](adr/0001-use-swift-swiftui-appkit.md) — Swift + SwiftUI (content) + AppKit (windows/system). Target: macOS 14 Sonoma, Swift 5.9+.

## 1. High-level shape

```
┌────────────────────────────────────────────────────────────┐
│ top-drop-notch (agent app, LSUIElement)                   │
│                                                            │
│  AppCore            — lifecycle, services wiring, settings │
│  WindowEngine       — NSPanel(s): notch island, HUDs,      │
│                       floating island, tray                │
│  IslandUI           — SwiftUI: states, pages, widgets      │
│  LiveActivities     — activity queue + pill layout         │
│  MediaService       — now-playing (public path + fallback) │
│  TrayService        — file tray model + drag sessions      │
│  ClipboardService   — NSPasteboard polling + store         │
│  HotkeyService      — Carbon global hotkeys                │
│  Settings           — native grouped Form + search         │
│  StatusBar          — NSStatusItem menu                    │
│  Extensions (later) — in-process modules via protocols     │
└────────────────────────────────────────────────────────────┘
```

Single process, single window server connection. SwiftPM executable target first (no Xcode project until signing/notarization forces one — keeps the repo diff-friendly for agents).

## 2. Window strategy (the core of the app)

### Island panel (the notch overlay)

- `NSPanel` subclass, `styleMask = [.borderless, .nonactivatingPanel]`
- `level = .statusBar` while idle; `.screenSaver` when it must sit above full-screen video
- `collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]`
- `hidesOnDeactivate = false`, `isFloatingPanel = true`, `becomesKeyOnlyIfNeeded = true`
- `ignoresMouseEvents = false` only over hit-tested island region — **transparent window must not eat clicks meant for the menu bar**: the panel spans the top strip, but mouse events outside the island content rect are forwarded (acceptsFirstMouse / hit-test override).
- Content: `NSHostingView(rootView: IslandView(...))`
- App: `NSApplication.setActivationPolicy(.accessory)` (no Dock icon)

### Geometry

```swift
// Conceptual — actual code in M1
let notchHeight = screen.safeAreaInsets.top
let left  = screen.auxiliaryTopLeftArea   // .maxX of left band
let right = screen.auxiliaryTopRightArea  // .minX of right band
// notch width = right.minX - left.maxX; zero-width → notchless display
```

- Notched display → island hugs cutout; closed state renders as shoulders (32pt fillets) beside the cutout.
- Notchless display → floating pill at top-center (user-positionable), menu-bar fallback.
- Re-frame on `NSApplication.didChangeScreenParametersNotification` and display connect/disconnect; per-display settings keyed by `NSScreen` device description.

### Multiple panels

| Panel | Level | Purpose |
|---|---|---|
| Island | statusBar / screenSaver | Main surface |
| HUD (volume/brightness) | statusBar | Beside island, joins its window group |
| Lock-screen overlay | screenSaver | Only while locked (event taps on `com.apple.screenIsLocked`) |
| Floating player | floating (user choice: above-all vs pin-to-desktop) | Desktop media player |

Window-frame morphing (closed → expanded) runs through `NSAnimationContext` synchronized with the SwiftUI content transition — one timeline, both layers.

## 3. Island state machine

```
        hover/intent            dismiss/delay
compact ──────────▶ expanded ────────────────▶ compact
   │                   │
   │ drag file over    │ page swipe (Home / Tray / Widgets)
   ▼                   ▼
 acceptingDrop       pages[]
```

- Owner: `IslandController` (AppKit side) holds panel frame + level.
- Content: `PhaseAnimator`/`KeyframeAnimator` on the SwiftUI side.
- **Interruptible:** every transition re-targets from current presentation values (no queued animations).
- Live activities attach as pills in the two "wings" beside the island: primary activity gets the main seat; others compress into pills (elastic merge — see [design-language §5](design-language.md)).

## 4. Services

| Service | Mechanism | Notes |
|---|---|---|
| **MediaService** | *Default:* AppleScript/JXA (`osascript`) polling for Music/Spotify; artwork via script. *Opt-in:* MediaRemote adapter (external helper process, post-macOS 15.4 entitlement gate) with automatic fallback to the public path. Publishes `NowPlaying` state. | Never private-API-only. See [permissions](permissions.md). |
| **ClipboardService** | `NSPasteboard.general.changeCount` polling (250–500ms + active window). Store: local, SQLite or JSON-lines; honor `org.nspasteboard.ConcealedType` + transient types — never record | Search index over in-memory entries. |
| **TrayService** | Accepts drops via `NSDraggingDestination` on the island panel + `.onDrop` in SwiftUI; model = ordered file refs, pins, retention timer | Shake-to-summon uses `NSEvent` drag-phase mouse deltas (M4) |
| **HotkeyService** | Carbon `RegisterEventHotKey` (via HotKey lib) + `NSEvent.addGlobalMonitor` where recording is needed | Recorder with conflict detection comes in M5 |
| **Settings** | `@AppStorage`/UserDefaults-backed `@Observable` store; native grouped `Form` with search | Deep-linkable panes |
| **StatusBar** | `NSStatusItem` (not MenuBarExtra — we need custom menu construction + badge) | Hideable; hidden by default? No — default visible, user can hide |

Threading: all UI on `@MainActor`; services are actors or `@MainActor` where trivial (clipboard polling is cheap); no GCD except bridging AppKit callbacks.

## 5. Extension model (post-MVP, M6)

Deliberately simpler than Droppy's 170-type SDK — start minimal, evolve:

```swift
// v1: in-process protocol, statically linked modules (no dlopen yet)
protocol IslandModule {
    static var id: String { get }
    var widget: (any View)? { get }        // notch widget slot
    var liveActivity: ActivitySpec? { get } // pill
    var shortcut: ShortcutSpec? { get }
}
```

- Modules registered in `AppCore` at launch; enable/disable = setting per module (off ⇒ no widget, no shortcut registration, no timer — same rule as Droppy's "an off droplet costs nothing").
- `dlopen` of external Swift dynamic libraries + JSON manifest only if/when third-party distribution happens — that's a store decision, not a v1 decision.
- **Cut line:** if the extension protocol isn't pulling weight by M6, keep modules as plain Swift packages linked into the app; the protocol boundary still pays off as organization.

## 6. Data & privacy

- Local-first: clipboard, tray, settings all on-device (UserDefaults/SQLite in `Application Support`).
- No analytics/telemetry in v1.
- Cloud features (file sharing) deferred indefinitely — out of scope until core is excellent.
- Future E2EE sync: out of scope for all milestones here.

## 7. Repo / build layout

Dependency direction is one-way: `DesignKit` ← `WindowEngine` ← `IslandUI` ← executable.

```
top-drop-notch/
├── Package.swift              # SwiftPM manifest (tools 5.9, macOS 14)
├── Sources/
│   ├── DesignKit/             # design tokens: Metrics, IslandColor, IslandAnimation
│   ├── WindowEngine/          # NotchGeometry, IslandPanel, IslandState, IslandController
│   ├── IslandUI/              # SwiftUI components + IslandRootView
│   └── TopDropNotch/          # @main entry (AppCore wiring arrives with M2+)
├── Tests/WindowEngineTests/   # geometry fixtures, state-machine transitions
├── docs/                      # ← you are here
├── cliff.toml                 # git-cliff changelog config
└── .github/workflows/         # ci: build, test, changelog validation
```

Later milestones add `Services/` (media, clipboard, tray, hotkeys) and `SettingsUI/` as targets when those features land — no empty placeholder targets up front.

Sign/notarize steps (M5+) will likely introduce an Xcode project or `xcodebuild` wrapper — keep SwiftPM as source of truth until then.

## 8. Testing strategy

- **Unit:** notch geometry math (fixture screens), island state machine transitions (interruptible re-targeting), clipboard concealment filtering, tray retention rules.
- **Swift Testing** (`@Test`/`#expect`) — modern, fast, agent-friendly.
- **Snapshot/visual:** deferred; rely on design tokens + review recordings.
- **Manual matrix (every PR touching windows):** notched MacBook, external display, notchless iMac if available, full-screen app, Reduce Motion, dark/light.
