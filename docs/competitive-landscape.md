# Competitive landscape — macOS notch / Dynamic Island apps

> **Last reviewed:** 2026-10-08. Sources: [getdroppy.app/compare](https://getdroppy.app/compare) (self-interested but cites versions), competitor sites, GitHub, Setapp/App Store listings. Prices as listed; promos change.

## Direct competitors

| App | Price | Min macOS | Strengths | Gaps |
|---|---|---|---|---|
| **Droppy** (our inspiration) | $9.99 once, 2 Macs | 14 | Broadest scope: tray, clipboard, 41 extensions, lock screen, MCP, iOS sync; excellent craft; $9.99 value anchor | Breadth over depth in some features; closed source; private-API dependence |
| **Alcove** | $14.99 once | **15** | Media depth: fluid transitions, notifications, live activities, gestures, HUDs, lock-screen widgets | Media-focused; macOS 15+ excludes Sonoma machines |
| **NotchNook** | $25 lifetime (5 devices) or $3/mo (promo $15/$2); in Setapp | 14.6+ | Media controls, file tray, AirDrop, calendar, mirror; established | No extension ecosystem; pricier; hover-to-peek needs a notch |
| **NotchPop** | — | — | Closest positioning clone: "native productivity island", file shelf, clipboard, media, timers, 20+ native extensions, notchless island; markets native Swift/SwiftUI | New/unproven; direct rival for our wedge |
| **NotchNest** | Free + IAP ($14.99 lifetime / $2.99 mo) | MAS | Apple Intelligence clipboard, calendar, notes, Pomodoro, AirDrop | MAS sandboxed; IAP friction |
| **Kishi Notch** | — | 14 | Native Swift island + menu-bar battery | Shallow feature set |
| **DynamicLake Pro** | $13.99+ | — | Productivity tools + island | Older aesthetic (Dynamic Lake style) |
| **Canopy / Seam / Perch** | €15 / $19.90 / $24.99–49.99 | — | Various tray/media takes | Pricey for scope |

## Free / open source

| App | Notes | Use to us |
|---|---|---|
| **The Boring Notch** (10.2k★) | Media + battery basics, Metal visualizer, MediaRemote adapter pattern | Study window setup, now-playing fallback architecture |
| **Atoll** | Free, beta churn | Feature parity floor |
| **MewNotch** | Free, OSS | — |
| **NotchDrop** (MIT) | Drop-file focused shelf | Tray drag-and-drop reference |
| **NotchApp** | "Dynamic Island activities, clipboard, file shelf, media, calendar — SwiftUI + AppKit, no deps" | **Closest OSS reference for our exact stack** — read before writing window code |
| **DynamicNotch** (378★) | NotchEngine queue-driven presentation state machine, floating-capsule fallback | Presentation-queue design reference |
| Frameworks: **DynamicNotchKit** (MIT), **opennook** | Reusable notch chrome, settings, hotkeys | Consider vendoring ideas (not code, license permitting) |

## Market observations

1. **Price bands:** free OSS anchors the bottom; paid clusters at $9.99–$25 one-time, one subscription outlier ($3/mo NotchNook). One-time pricing is table stakes for this category.
2. **Differentiation axes:** (a) scope/breadth = Droppy; (b) media depth = Alcove; (c) tray+clipboard basics = NotchNook; (d) native-craft + extension count = NotchPop.
3. **macOS 14 floor is a real gap** — Alcove requires 15; we target 14 like Droppy/NotchNook.
4. **Notchless/external-display support is expected** (floating island + menu-bar integration); hover-to-peek without a notch is the commonly admitted limitation.
5. **Extension ecosystems are rare** — only Droppy (41) and NotchPop (20+) claim one. A lightweight extension model is table stakes for a credible entrant *if* we can keep it simple (see [architecture.md](architecture.md) §Extensions).
6. **OSS precedent de-risks everything**: our stack decision ([ADR-0001](adr/0001-use-swift-swiftui-appkit.md)) has five working reference apps.

## Where we can win (working hypothesis — revisit at end of M2)

- **Open source + free** (or free tier) against $10–25 paywalls, with Droppy-grade motion.
- **Day-one notchless mode** done properly (many rivals treat it as an afterthought).
- **Privacy-by-default**: no private API required for core paths (public now-playing path first; MediaRemote opt-in), which also keeps an App Store build possible later.
- **Not** winnable: raw feature count at launch vs 41 extensions. Sequence it (see [roadmap.md](roadmap.md)).
