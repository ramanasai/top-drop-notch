# Roadmap

Milestones with **exit criteria** (verifiable) and **cut lines** (what we deliberately don't do). The executable checklist derived from this lives in [../TODO.md](../TODO.md). Nothing merges to `main` directly — each milestone lands as small PRs.

**Guiding sequence:** ship the daily-driver trio (hover-expand notch → now playing → file tray → clipboard) with excellent motion *before* breadth. See [product-research §6](product-research.md).

---

## M0 — Repo & process ✅ (this phase)

**Goal:** repo, rules, docs, tooling — so every later change is reviewable and changelogged.

Exit criteria:
- [ ] Public GitHub repo, `main` protected (PR-only, no direct pushes/merges)
- [ ] Conventional Commits + git-cliff changelog generating `CHANGELOG.md` in CI
- [ ] PR template, CI workflow (build/test placeholder → real at M1)
- [ ] Docs: research, competition, design language, architecture, ADR-0001, permissions, roadmap, TODO, development guide, skills
- [ ] AGENTS.md behavioral rules active

## M1 — Skeleton that lives at the notch

**Goal:** an agent app that shows a black island at the notch and gets the windowing right — the hardest foundational risk burned down first.

Exit criteria:
- [ ] SwiftPM executable builds (`swift build`) and runs as `LSUIElement` (no Dock icon)
- [ ] Non-activating borderless `NSPanel` at correct level, all spaces, above full-screen when needed
- [ ] Notch geometry detected (`safeAreaInsets` + `auxiliaryTop*Area`); **notchless fallback pill** on external displays
- [ ] Closed state renders: black cutout-hugging bar with 32pt continuous shoulders
- [ ] Hover over island region expands it (shared spring, interruptible); pointer-leave auto-collapse with delay
- [ ] Clicks outside island content don't get eaten (menu bar usable)
- [ ] Re-frames on display connect/disconnect & resolution change
- [ ] Reduce Motion: expand = cross-fade, no morph
- [ ] Unit tests: geometry math, state-machine transitions
- [ ] Settings window opens (native grouped form shell, empty)

**Cut line:** no media, no pages, no widgets yet — island may show a static placeholder.

## M2 — Now Playing + island pages

**Goal:** the signature feature: music in the notch.

Exit criteria:
- [ ] MediaService public path (AppleScript/JXA) shows title/artist/artwork for Music + Spotify
- [ ] Compact state shows mini artwork; expanded shows full player: artwork, title, artist, play/pause, next/prev
- [ ] Elastic prev/next swipe on artwork (interruptible)
- [ ] Playback controls work; artwork cached per track
- [ ] Page system: Home / Tray / Widgets via two-finger swipe + click targets
- [ ] No-playing state looks intentional (not an empty box)
- [ ] Manual matrix pass: notched, external, full-screen video, Reduce Motion
- [ ] Opt-in MediaRemote adapter behind a setting, with automatic fallback (stretch — defer to M5 if risky)

## M3 — File tray

**Goal:** drop files on the notch, hold them, get them out.

Exit criteria:
- [ ] Drag file(s) over island → island expands to "accepting" state
- [ ] Files land in Tray page: icon + name + count; ordered, pinned items survive cleanup
- [ ] Drag out to destination (Finder/apps) works; drag sessions torn down cleanly
- [ ] Retention: auto-cleanup timer with pin exceptions; cleanup on quit setting
- [ ] Drop-triggered action stub (e.g. "Reveal in Finder" / "Copy path") — full quick-action tiles deferred
- [ ] Unit tests: tray model (pins, retention, ordering)

**Cut line:** shake-to-summon floating tray, quick-action tiles, cloud sharing → M6+ backlog.

## M4 — Clipboard history

**Goal:** one shortcut away from everything you've copied.

Exit criteria:
- [ ] ClipboardService polls changeCount; stores text, rich text, links, images (size-capped), file refs
- [ ] **Never records concealed/transient entries** (`org.nspasteboard.ConcealedType` etc.) — test proves it
- [ ] History UI: searchable list, type filters, pin, copy-on-select, delete, clear-all
- [ ] Global hotkey opens history panel (Carbon via HotKey) with focus in search
- [ ] Store survives relaunch; no network ever touches clipboard data
- [ ] Unit tests: concealment filtering, store round-trip, dedup

## M5 — Live Activities + polish pass

**Goal:** the status layer beside the island + the craft pass that makes it feel premium.

Exit criteria:
- [ ] Activity engine: queue, primary-seat + pill layout, elastic merge/leave
- [ ] Ship ≥4 activities: volume HUD, brightness HUD, play/pause track toast, focus (Pomodoro) timer scrub
- [ ] Keyboard shortcut recorder (conflict detection) + settings for hover delays, auto-collapse, animation speed
- [ ] Settings search across all settings
- [ ] Accessibility audit: VoiceOver announces state changes, focus order, labels everywhere
- [ ] Performance: no main-thread stalls during animation; CPU idle ≈ 0 when island closed
- [ ] Menu bar item (status item) with hide/show + quit + settings

**Cut line:** lock screen, notification replies, meeting controls → backlog.

## M6 — Extension system v1 + release engineering

**Goal:** prove the module model; ship something real to users.

Exit criteria:
- [ ] `IslandModule` protocol (see [architecture §5](architecture.md)); ≥3 real modules implemented *through it* (e.g. stay-awake, Pomodoro, window-snap — pick small winnables)
- [ ] Enable/disable per module: off ⇒ zero timers, zero shortcuts, zero views
- [ ] Module settings surface in Settings automatically
- [ ] Code signing + notarization pipeline (Developer ID); Sparkle or custom update check (decision recorded as ADR)
- [ ] App icon, about window, version display
- [ ] Release flow: tag `vX.Y.Z` → git-cliff generates release changelog → CI builds artifacts
- [ ] First public release (GitHub Releases, notarized DMG/zip)

**Cut line (explicitly deferred, in priority order):** floating player, lock screen, notch "camera band" widgets, extension `dlopen` + store, shake-to-summon tray, cloud sharing, iOS companion, MCP server.

---

## Backlog (ordered, unscheduled)

1. Floating player (3 morphing sizes, queue, lyrics)
2. Lock-screen cards + full-screen artwork
3. Camera-band header widgets (exact Droppy-style geometry)
4. External `dlopen` extensions + manifest + store
5. Shake-to-summon floating tray + multiple trays
6. Quick-action tiles (AirDrop, mail, convert, share link)
7. Notchless island customization (position, size, per-display theming)
8. Per-app volume (needs System Audio Recording tap)
9. Notification display + inline reply
10. iCloud/E2EE sync + iOS app

Update this backlog when cutting scope from milestones — never silently drop.
