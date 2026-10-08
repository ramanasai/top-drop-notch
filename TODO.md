# TODO — in-depth checklist

Phase-by-phase execution list derived from [docs/roadmap.md](docs/roadmap.md). Every PR should close items from exactly one phase (or the backlog). Link the item in the PR (`Closes` via issue preferred for multi-commit work).

**Rules:** never merge to `main` directly · Conventional Commits · regenerate `CHANGELOG.md` with `git-cliff` when user-visible · see [AGENTS.md](AGENTS.md).

Status legend: `☐` todo · `◐` in progress · `☑` done

---

## M0 — Repo & process

- ☑ Initialize git repo, public GitHub repo (`ramanasai/top-drop-notch`)
- ☑ Branch protection on `main`: PR-only, no direct pushes/merges, dismiss stale reviews, include administrators
- ☑ `AGENTS.md` — Karpathy-inspired behavioral guidelines + project rules
- ☑ `CLAUDE.md` → points to AGENTS.md
- ☑ git-cliff: `cliff.toml`, generated `CHANGELOG.md`, documented commands
- ☑ `.gitignore`, `LICENSE` (MIT)
- ☑ `.github/PULL_REQUEST_TEMPLATE.md`
- ☑ CI workflow: validate `cliff.toml` (`git-cliff --context`), changelog freshness check, `swift build`/`swift test` (gated until Package.swift exists)
- ☑ Docs: index, product research, competitive landscape, design language, architecture, ADR-0001, permissions, roadmap, development guide, skills, this TODO
- ☑ Skills installed (see [docs/skills.md](docs/skills.md))

## M1 — Skeleton at the notch

### Project scaffold
- ☑ `Package.swift`: executable + module targets (`DesignKit`, `WindowEngine`, `IslandUI`), macOS 14 platform, Swift 5.9 (`Services`/`SettingsUI` deferred until their features land)
- ☑ App entry: `@main` → `setActivationPolicy(.accessory)`; no Dock icon, no main menu
- ☑ Folder layout matches [docs/architecture §7](docs/architecture.md) (`AppCore`/services wiring arrives with M2)
- ☐ `swift build && swift test` green in CI on macOS runner *(workflow added; confirm on first PR run)*
- ☐ Verify: launch from terminal → process runs, no Dock icon, quit works *(manual)*

### Window engine (highest-risk foundation)
- ☑ `IslandPanel: NSPanel` — borderless, `.nonactivatingPanel`, `isFloatingPanel`, `canBecomeKey/Main = false`
- ☐ Window level: `.screenSaver` always (a `.statusBar`-idle → `.screenSaver`-on-fullscreen switch is a possible optimization, not yet implemented)
- ☑ `collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]`; `hidesOnDeactivate = false`
- ☑ Panel hosts `NSHostingView(IslandRootView)` via `IslandController.attach(content:)`; frame = island content only (closed/expanded morph)
- ☐ **Hit-testing:** panel currently spans only the island rect, so everything outside is pass-through by construction — *verify* menu-bar items beside the island remain clickable
- ☐ App never activates on hover/click (non-activating verified: frontmost app stays frontmost) *(manual)*
- ☑ Re-frame on `didChangeScreenParametersNotification` (display hot-plug / resolution change)
- ☑ Unit tests: panel geometry given fixture screen values

### Notch geometry
- ☑ `NotchGeometry` struct: cutout height (`safeAreaInsets.top`), left/right bands (`auxiliaryTopLeftArea`/`auxiliaryTopRightArea`), derived notch width, `isHardwareNotch` flag (controller reads `NSScreen`, geometry is pure/testable)
- ☑ Notched path: island hugs cutout + 32pt shoulders in frame math (closed-state *rendering* of the fillets: see Island states below)
- ☑ Notchless path: floating pill frame (`Metrics.Pill.size`, top-center) — same geometry type, zero-width bands
- ☐ Per-display geometry cache keyed by screen identifier *(controller currently tracks `NSScreen.main` only)*
- ☑ Unit tests: notched fixture, notchless fixture (zero-width bands), external-display fixture, clamped/negative values

### Island states & motion
- ☑ `IslandState` enum: `closed`, `expanded(page)`, `acceptingDrop` (transient `toast` lands with M4)
- ☑ `IslandController` (AppKit): panel frame morph via `NSAnimationContext`, durations paired with the SwiftUI spring (exact single-timeline sync = polish)
- ☐ Closed ↔ expanded on **hover** — wired via `onHover`, but *no configurable delays yet*; interruptible mid-motion to verify
- ☐ Click island → toggle *(done)*; click outside / Esc → collapse *(not yet)*
- ☑ Shared spring per [design-language §5](docs/design-language.md); `IslandAnimation` presets, no per-view springs
- ☑ Reduce Motion: cross-fade, no frame morph (`IslandAnimation.preferred(reduceMotion:)`, reduced morph durations)
- ☐ Closed-state rendering: pure black cutout region + **32pt shoulder fillets** blending into the menu-bar strip (current `IslandShell` uses the island radius — placeholder)
- ☑ Empty expanded state: placeholder card + `CameraBandHeader` (not a blank box)
- ☑ State-machine unit tests: hover-in/out ordering, drag transitions, page switches, rapid toggles settle correctly

### Settings shell
- ☐ Settings window: native grouped `Form`, sidebar panes (General placeholder)
- ☐ Opens from island + (temporary) menu bar; `⌘,` bound
- ☐ Pane: hover-expand delay, auto-collapse delay, animation speed, "show on notchless displays", "hide Dock icon" (label-only until implemented)

### M1 exit verification
- ☐ Manual matrix: notched MacBook, external display, full-screen video (level switch), menu-bar click-through, Reduce Motion, display hot-plug
- ☐ No focus stealing in any scenario (screen recording of frontmost-app indicator)

## M2 — Now Playing + island pages

- ☐ `NowPlaying` model: title, artist, artwork, isPlaying, position, duration, source
- ☐ `MediaService` — **public path**: JXA/`osascript` polling (≈1s + on-wake) for Music & Spotify; artwork extracted per track, cached in memory/disk
- ☐ Publish via `@Observable`; island subscribes (no polling in views)
- ☐ Compact state: mini artwork (when playing) or idle glyph (when not)
- ☐ Expanded player: artwork, title, artist, play/pause, prev/next — buttons wired to source
- ☐ Elastic prev/next swipe on artwork (gesture-driven translation + interruptible spring settle)
- ☐ Track-change animation: artwork cross-fade + title slide; artwork glow cached once per track (no per-frame blur)
- ☐ No-source/no-permission states: friendly "start Music or Spotify" hint + automation-permission deep link
- ☐ **Page system:** `IslandPage` = home / tray / widgets; two-finger swipe + click dots; page transition on shared spring
- ☐ Home page: placeholder widget slot (1 slot; layout honors camera-band avoidance from day one — even if empty)
- ☐ Tray page + Widgets page: labeled placeholders
- ☐ MediaRemote adapter spike (time-boxed): evaluate [ungive/mediaremote-adapter](https://github.com/ungive/mediaremote-adapter) helper — **decision recorded in ADR-0002**; ship as opt-in setting with fallback, or defer to M5
- ☐ Unit tests: MediaService parsing (fixture script output), page state transitions
- ☐ Manual: Music + Spotify, lock/unlock, sleep/wake, artwork missing, 200% display scaling

## M3 — File tray

- ☐ `TrayModel`: ordered `[TrayItem]` (file URL, name, icon, pinned, addedAt), publish, persist (bookmark-based refs)
- ☐ Drag over island → `acceptingDrop` state (island expands, drop affordance, haptic tick optional)
- ☐ Accept multi-file drops (`.onDrop` / `NSDraggingDestination`); import to model, not copies (copy on demand at consume time)
- ☐ Tray page UI: file icons+names, count badge, scroll if overflow, per-item context menu (Reveal in Finder, Copy path, Remove, Pin)
- ☐ Drag **out**: reconstruct drag session from tray items → Finder/apps work; sessions torn down on cancel/failure
- ☐ Pinned items survive auto-cleanup; unpinned retained for N minutes (setting); cleanup timer + "Clear unpinned" action
- ☐ Cleanup-on-quit setting; restore tray on relaunch (bookmarks still valid — handle dead paths gracefully)
- ☐ Drop on island while a **file manager drag in progress from another app** doesn't break the source drag (validate with Finder → island → back to Finder)
- ☐ Unit tests: ordering, pin/retention rules, persistence round-trip, dead-path handling
- ☐ Backlog stubs filed as issues (not built): shake-to-summon basket, quick-action tiles, cloud link

## M4 — Clipboard history

- ☐ `ClipboardService`: poll `changeCount` (active polling ~400ms when frontmost is "dirty-able", lazy otherwise — measure; simple fixed 500ms acceptable for v1)
- ☐ Entry model: kind (text/rich/link/image/file), preview, payload ref, source app (from `NSWorkspace` frontmost at capture), timestamp, pinned
- ☐ **Concealment filter:** skip when pasteboard types include `org.nspasteboard.ConcealedType` / transient flags — **unit-tested with fixture types**
- ☐ Dedup (move-to-top on repeat copy), size cap (images > X MB → store reference only or skip; decision documented in code comment)
- ☐ Store: Application Support (SQLite if trivial, else JSON-lines for v1), encrypt-at-rest decision deferred (local single-user; note in privacy doc)
- ☐ History UI panel (floating `NSPanel` or island Widgets page — **decision:** separate small panel triggered by hotkey, island shows badge only; revisit if scope creep)
- ☐ Search (substring, case-insensitive v1), type filter chips, pin, copy-on-select (write to pasteboard + optionally simulate ⌘V — v1: write only), swipe/ctx delete, clear-all with confirm
- ☐ Global hotkey (HotKey lib) → opens panel with **focus in search field** (first keystroke goes to search)
- ☐ Hotkey recorder UI (basic: record + conflict warning against system/in-app) — full conflict matrix is M5
- ☐ Clear-on-quit setting; pause-recording toggle in status menu
- ☐ Unit tests: concealment, dedup, store round-trip, preview truncation, search matching
- ☐ Manual: 1Password/Keychain copies never appear; large image copy doesn't stall UI

## M5 — Live Activities + craft pass

### Activity engine
- ☐ `Activity` model: id, priority, expiry, compact content (icon+text), expanded content, pill or main-seat eligibility
- ☐ Queue: main seat = highest priority non-expired; others → wing pills; enter/leave animates with elastic merge ([design-language §5](docs/design-language.md))
- ☐ Tap pill → promote to main seat (displaces current, returns on timeout)
- ☐ Ship activities: **volume HUD** (system volume via `CoreAudio` get/set), **brightness HUD** (`CoreGraphics` display brightness), **track-change toast**, **Pomodoro focus timer** (scrubbable, ticks beside island, persists)
- ☐ HUD placement beside island respects geometry on notchless displays (pills under the pill)

### Interaction & settings polish
- ☐ Shortcut recorder: conflict detection (system + in-app), rebind UI, "restore defaults"
- ☐ Settings: hover delays (per main/external), auto-collapse, animation speed, right-click behavior, hide-in-fullscreen, hide-in-Mission-Control, per-app hide list (stub OK)
- ☐ Settings search (fuzzy, across all panes)
- ☐ Status bar item: show/hide island, pause clipboard, open settings, check updates, quit; hideable; optional Dock icon setting
- ☐ Window level auto-upgrade verified against: full-screen video, screen sharing, Mission Control, Stage Manager

### Quality gates
- ☐ Accessibility audit: labels/values, focus order, VoiceOver announces compact↔expanded, Differentiate Without Color
- ☐ Performance: Instruments — no main-thread stalls >16ms during morph; CPU ≈0% idle with island closed; clipboard poll cost measured; memory stable over 24h soak
- ☐ Error paths: automation denied, hotkey unavailable (taken), display unplugged mid-drag, pasteboard cleared while panel open
- ☐ Design review against [design-language.md](docs/design-language.md) — token audit (no one-off colors/radii/springs)

## M6 — Extensions v1 + release

### Extension system
- ☐ `IslandModule` protocol per [architecture §5](docs/architecture.md) (widget/liveActivity/shortcut/settings slots, all optional)
- ☐ Registry: modules listed at launch; enable/disable toggles; **off ⇒ no timers, no shortcut registration, no views** (assert in debug)
- ☐ Module settings auto-surface in Settings ("Modules" pane)
- ☐ Implement 3 real modules *through the protocol* (candidates: Stay-awake, Pomodoro (move from M5 activity), Window snap hotzones) — the protocol must earn its keep on real cases
- ☐ Document: "writing a module" (docs + example)
- ☐ Decision: `dlopen` external modules — **deferred with rationale** (ADR-0003 or backlog note)

### Release engineering
- ☐ Apple Developer account + Developer ID application certificate (secrets in Keychain/CI secrets, never repo)
- ☐ Signing: `codesign` hardened runtime entitlements list minimal (automation, no sandbox v1)
- ☐ Notarization + staple in CI or release script
- ☐ App icon (template + asset catalog), About window, version/build display
- ☐ Update mechanism decision → ADR-0002/0003: (a) Sparkle, (b) GitHub Releases + manual, (c) custom JSON feed via git-cliff-tagged releases — pick one, implement
- ☐ Release script: `git-cliff --tag vX.Y.Z -o CHANGELOG.md` → commit via PR → tag → CI builds notarized artifact → GitHub Release
- ☐ First public release checklist: README screenshots/recording, min-system requirements stated, privacy statement (local-first), license, issue templates enabled

### M6 exit verification
- ☐ Fresh-machine install test (notarized, no dev tools) from GitHub Release
- ☐ Upgrade test: v0.1 → v0.2 keeps settings/tray/clipboard
- ☐ Tag → changelog → release pipeline exercised end-to-end

---

## Backlog (unscheduled — see [roadmap](docs/roadmap.md) backlog for order)

- ☐ Floating player (3 sizes, queue, lyrics)
- ☐ Lock-screen cards + full-screen artwork
- ☐ Camera-band header widgets
- ☐ `dlopen` extensions + manifest + store
- ☐ Shake-to-summon floating tray + multiple trays
- ☐ Quick-action tiles / share link
- ☐ Notchless island full customization
- ☐ Per-app volume (CoreAudio tap)
- ☐ Notification display + inline reply
- ☐ iCloud/E2EE sync + iOS companion

## Housekeeping

- ☐ Triage backlog → GitHub issues quarterly; keep this file the source of truth for *phased* work only
- ☐ After each milestone: update roadmap checkboxes, regenerate changelog, tag release
