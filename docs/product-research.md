# Product research: Droppy (getdroppy.app)

> **Last reviewed:** 2026-10-08 · Sources: [getdroppy.app](https://getdroppy.app/), [docs](https://getdroppy.app/docs), [/droplets](https://getdroppy.app/droplets), [/changelog](https://getdroppy.app/changelog), [/compare](https://getdroppy.app/compare).
> This is a research snapshot of the product that inspired this project — for us to learn from, not to copy verbatim. See also [competitive-landscape.md](competitive-landscape.md).

## 0. Snapshot

| | |
|---|---|
| What | Native macOS app turning the notch (or a floating island on notchless displays) into a productivity surface: file tray, clipboard history, media player, live status HUDs, lock-screen widgets, extension system |
| Price | $9.99 one-time, lifetime; 1 license = 2 Macs; 3-day full trial; 14-day refund; regional pricing |
| Requirements | macOS 14+, Apple Silicon + Intel, notched and notchless |
| Companion | Free iPhone app (TestFlight): clipboard/files/notes sync E2EE, Live Activities, widgets |
| Author | Solo dev; active Discord + public feature-voting board |
| Model | Local-first; only cloud share links and E2EE sync touch servers |
| Cadence | 95 releases in ~8 months; stable/beta/nightly channels |

## 1. Feature inventory

### 1.1 Core surfaces (not extensions)

- **The notch / Dynamic Island** — grows out of the hardware notch, or a floating island pill on notchless displays; chosen per display. Pages: **Home** (widgets), **Tray** (files), **Widgets** (icon grid). Up to 4 Home widgets, favorites, reorderable.
- **File Tray** — drag anything to top of screen (or shake while dragging); holds files until dragged out; pinned items survive cleanup; lives in notch, floating, or both.
- **Floating tray ("basket")** — tray summoned to the cursor: shake-to-reveal with sensitivity setting, instant-appear delay, or hold-a-key while dragging; multiple trays + tray switcher.
- **Quick Action tiles** — drop a file on a tile → share link, AirDrop, mail, convert, etc.
- **Clipboard history** — text/richtext/links/images/colors/file refs; searchable; type filters, tags, pins; source-app icon; honors `org.nspasteboard.ConcealedType` (password-manager copies never recorded); imports from Maccy/Raycast/Alfred/Clipy.
- **Live Activities** — the status layer. System: volume/brightness/keyboard-brightness HUDs, battery, headphone battery, Caps Lock, Focus changes, drive mount/eject, network/VPN status, screen-recording controls. Media: artwork/title/scrubber, Playing Next, AirPlay picker, audio visualizer, motion artwork. Multiple activities: primary in the main seat, others as pills beside it.
- **Floating player** — menu-bar item → dropdown → draggable desktop window; three morphing sizes (Mini / Player / Expanded); queue, synced lyrics, scrubber, volume, output picker.
- **Lock screen** — cards above login (Now Playing, timers), tap album → full-screen animated artwork, status chips, iOS-style edge sliders.
- **Droppy Cloud** — drop file on notch → share link; 200 MB/file, 1 GB total, 25 files, auto-expire 3 days.
- **MCP server** — local stdio helper exposing clipboard search, tray files, media control, etc. to Claude/Cursor/Codex, with per-app approval by code signature.
- **Menu bar** — status menu; no Dock icon by default (agent app); optional Dock icon + login item.
- **Settings** — native grouped form (System Settings look), full search across settings + extension catalog.

### 1.2 Extensions ("Droplets") — 41 marketed / 40 documented

Free, all included, **only run when switched on** (off = no widget, no shortcuts, no permission use). Categories:

- **Productivity (12):** Alfred workflows, shell-in-notch, calendar/tasks, Pomodoro, meeting controls, notes, full Spotlight-replacement launcher (search, math, unit conversion, AI chat, uninstall), Obsidian, weather, radial action menu at cursor, teleprompter, select-text-anywhere action bar.
- **Media (5):** Spotify, Apple Music, synced lyrics, per-app volume sliders, YouTube Music.
- **AI (3):** background removal (on-device model), on-device voice transcription, live coding-agent progress + plan-usage rings.
- **Capture (3):** screenshot/element capture with background editor, camera preview in notch, OCR text capture.
- **Files (6):** Finder services, video compress to target size, cloud share, PDF compress, converter, LocalSend.
- **System (11):** window snapping, notifications-with-reply, stay-awake, smooth scrolling, menu-bar tidier, mechanical keyboard sounds, system stats, emoji picker, "laptop opens like a Duo" hinge effect, uninstaller, window switcher.

**Surface types an extension can provide:** notch widget, live activity, lock-screen chip, global shortcut, radial-menu button, quick-action tile, menu-bar entry, file action, Finder action, media widget, iPhone counterpart.

**Platform:** each extension is a Swift package building a dynamic library loaded in-process via `dlopen`, with a `droplet.json` manifest (surfaces/capabilities), a hosted store reviewed via merge requests with CI build+sign, and a public SDK (~170 API types) with version gating.

## 2. UI/UX design language (as documented by their SDK)

Summarized because we'll build our own equivalent — full detail to be mirrored in [design-language.md](design-language.md):

- **Dark chrome always** — black at the notch melting into glass ("Dynamic Glass"); on notchless displays the island is full glass. Optional "hide physical notch" black bar.
- **Flat, not glossy** — no borders, no gradients (sole exception: settings sidebar tiles); surfaces separated by fill contrast only; sentence case everywhere.
- **4pt spacing grid**, tiered corner radii always with **continuous corners**.
- **Buttons = flat white wash**, semibold glyph, 0.94 press scale; diameters 34 (solo) / 28 (paired) / 24 (inline). Live-activity rows: 37pt row, 13pt glyphs, 12pt labels, 24pt circular controls.
- **Notch geometry** — shelf row starts cutout height + 10pt below screen edge, 48pt in from each shoulder; cards 17.5pt from walls; card radius 18pt; 32pt shoulders; camera-band avoidance (headers lift into the bands beside the camera).
- **Motion** — fast-open, **interruptible mid-motion**, elastic pill merging/stretching for live activities, track swipes with elastic stretch, player sizes morph continuously and "follow your fingers", Reduce Motion respected, motion artwork pauses with playback.
- **Settings panes use unmodified macOS controls** — deliberately native.

## 3. Interaction patterns

| Trigger | Behavior |
|---|---|
| Hover | Opens the island (auto-expand toggle + per-display-class delay) |
| Drag onto it | Opens to accept the drop, wherever the drag began |
| Shake while dragging | Floating tray flies in to hold files; sensitivity adjustable; alternatives: delay-based, or hold-a-key |
| Click | Configurable action |
| Two-finger swipe | Page between Home/Tray/Widgets, scrub media, elastic track-skip; on floating player: vertical = grow/collapse, horizontal = prev/next |
| Right-click | Settings or hide surface (user's choice) |
| Hold modifiers | Hold-to-reveal combo (for notches covering menu-bar items) |
| Keyboard | Nothing bound by default; full shortcut recorder with conflict detection; hyper-key support |
| Drop file on notch | Tray opens; quick-action tiles → share link in seconds |
| Lock screen | Tap album → full-screen art; edge sliders |

## 4. Permissions (and what it teaches us)

Requested **only when a feature needs it**, with a Settings → Permissions page that re-prompts and deep-links to System Settings:

- **Accessibility** — overlay windows, global shortcuts, acting on other apps.
- **Screen Recording** — reading pixels behind the overlay so the notch blends with the wallpaper; capture features.
- **System Audio Recording** — visualizer + per-app volume (levels read, never recorded).
- **Input Monitoring** — keys that must be seen before other apps swallow them.
- **Automation (AppleScript)** — Music/Spotify/meeting-app control.
- **Mic / Camera / Bluetooth / Calendars / Reminders / Contacts / Full Disk** — per-feature.

Our equivalent goes in [permissions.md](permissions.md).

## 5. Architecture hints (from docs + changelog + sibling open-source)

- Native Swift, SwiftUI + AppKit hybrid; AppKit-level drag sessions, crosshair capture, `setFrame` ↔ SwiftUI re-entrancy work visible in changelog.
- Extensions = Swift dynamic libraries `dlopen`'d in-process + JSON manifest + protocol-based surface registration; store = reviewed GitLab MRs with CI signing.
- Notch overlay = borderless panel positioned from `NSScreen.safeAreaInsets` / `auxiliaryTop*Area`; Screen Recording used to sample wallpaper pixels behind the surface.
- Now playing = private MediaRemote (survived macOS 15.4+ entitlement gate via helper-process workaround) + AppleScript/JXA for Spotify/meeting apps.
- Graphics = Metal-cached album-art glow rasterized once per track; animated artwork respects playback state and Reduce Motion.
- Backend = Cloudflare Worker for releases, Stripe checkout, Keychain-stored license; MCP helper as separate stdio executable.

## 6. What this teaches *our* product (conclusions)

1. **The notch overlay itself is commodity** — four free open-source implementations exist. The moat is (a) an extension platform, (b) surface density done tastefully (exact geometry, interruptible morphs, camera-band avoidance — all documentable), (c) distribution.
2. **Our wedge should be decided before M3** — candidate wedges: open-source/free tier, best-in-class media island depth (Alcove's play), or a narrower daily-driver trio (hover-expand notch + shake-to-summon tray + clipboard) with flawless motion. Out-feature-counting 41 extensions solo is not winnable.
3. **Ship the daily-driver trio first with excellent motion**; a launch with 3 polished features beats 40 mediocre ones.
4. **Document our own design tokens early** (see [design-language.md](design-language.md)) so agents and humans build against the same constants.
5. **Permissions asked lazily, per feature, with a re-prompt page** — copy this pattern, it's correct UX and good privacy posture.
