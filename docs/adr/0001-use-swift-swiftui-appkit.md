# ADR-0001: Use Swift + SwiftUI (content) + AppKit (windows), not GPUI/Rust

- **Status:** Accepted
- **Date:** 2026-10-08
- **Context:** Building a macOS notch-overlay app (Dynamic-Island-style panel at the hardware notch, morphing animations, live activities, drag-and-drop file tray, clipboard history, now-playing controls, extension system). Minimum target macOS 14 Sonoma. Two candidate stacks: GPUI (Zed's Rust UI framework) vs Swift with SwiftUI + AppKit.

## Decision

**Swift + SwiftUI for content and motion; AppKit for windowing and system integration. No GPUI.** No hybrid.

## Comparison

| Axis | GPUI (Rust) | Swift + SwiftUI/AppKit | Winner |
|---|---|---|---|
| Overlay window control | Only 3 hard-coded window levels (`normal`, `floating`, `popup`); no public API for `window.level`, `collectionBehavior`, `ignoresMouseEvents`, `hidesOnDeactivate`; reaching them means forking GPUI's unsafe `msg_send!` layer | First-class public API: `NSPanel(.borderless, .nonactivatingPanel)`, `.statusBar`/`.screenSaver` levels, `collectionBehavior`, `ignoresMouseEvents` | **Swift** |
| Menu bar / NSStatusItem | Not available. macOS tray PR in limbo; community `gpui-tray` macOS backend is a non-functional stub; background/tray agent mode an unresolved discussion | `MenuBarExtra` / `NSStatusItem`, `LSUIElement` — standard | **Swift** |
| Notch geometry | Not exposed; you'd FFI `NSScreen.safeAreaInsets` + `auxiliaryTopLeftArea/RightArea` yourself | Public API, used by 5+ open-source notch apps | **Swift** |
| Motion | Good spring system (`SpringAnimation`, `AnimationPhase`) — GPUI's strongest suit | `PhaseAnimator`, `KeyframeAnimator` (macOS 14 = our floor), `matchedGeometryEffect`, `withAnimation`; window-frame morphs via `NSAnimationContext` — must be AppKit anyway | **Swift (slight)** |
| Now playing | No bindings; write `objc` FFI yourself. Same private-API fragility as Swift, but 10× more plumbing | AppleScript/JXA default path; MediaRemote adapter path documented and battle-tested (boring.notch, Islet) | **Swift** |
| Drag-and-drop | Basic `ExternalPaths` drop delivery; no `NSDraggingInfo` affordances; Finder-drop support an open work item | `NSDraggingDestination` / `.onDrop` — decades-stable | **Swift** |
| Global hotkeys | No API; own Carbon/`CGEventTap` FFI | [HotKey](https://github.com/soffes/HotKey) (Carbon) or `NSEvent.addGlobalMonitor` — one-liners | **Swift** |
| Clipboard | Own FFI + polling semantics | `NSPasteboard.changeCount` polling — ~20 lines | **Swift** |
| Accessibility/VoiceOver | AccessKit landed but limited, not wired into components; VoiceOver on custom GPU views unproven | `NSAccessibility` + SwiftUI semantic elements work out of the box | **Swift** |
| Reference implementations | Zero notch/overlay apps; zero NSStatusItem precedents | NotchApp (feature-for-feature Droppy-like), DynamicNotch, boring.notch (10k★), Islet, Atoll, XNook + frameworks DynamicNotchKit, opennook | **Swift** |
| Licensing | Apache-2.0 (fine) | Apple frameworks, no obligations | Tie |
| Distribution risk | Same private-API caveats (platform, not language) + you own the bindings | Same caveats; ecosystem already solved macOS 15.4+ MediaRemote entitlement gate with drop-in adapters | **Swift** |
| Governance/maintainability | Zed has publicly **paused GPUI for non-Zed needs** ("major brakes… push off anything not directly related to Zed's use case"); upstream rejects non-Zed feature PRs; community fork (`gpui-ce`) ~381 commits behind, founder skeptical of it | Decade-stable Apple APIs (`NSPanel`, `NSStatusItem`, `NSPasteboard`, Carbon hotkeys all present in macOS 26); active open-source community maintaining exactly this app category | **Swift** |
| Cross-platform (GPUI advantage) | Windows/Linux support | None | GPUI — but **worthless for a notch-specific product** |

### The hybrid (GPUI inside an AppKit panel) was rejected because

1. No supported seam — GPUI *owns* its `NSWindow`; reparenting means unsafe surgery against private `MacWindowState`, rebased on every GPUI revision.
2. All system integration would still be written in Swift/ObjC (GPUI provides none of it), so GPUI would only render the island — where SwiftUI is already sufficient.
3. Two toolkits = two animation clocks, two text/IME stacks, two accessibility trees in one small overlay window.

## Consequences

- **Positive:** every requirement is public API; five+ working reference apps; product work starts immediately instead of maintaining a GPUI fork; VoiceOver works from day one.
- **Negative:** no Rust in the stack (if the team preferred Rust, that preference loses); private-API areas (MediaRemote) must be handled with the opt-in + fallback pattern regardless of language.
- **Neutral:** extension system is Swift-protocol + `dlopen` in-process (mirrors Droppy's Droplets), with XPC reserved for crash isolation if ever needed.

## Concrete shape (feeds [../architecture.md](../architecture.md))

- `LSUIElement` agent app; borderless `.nonactivatingPanel` at `.statusBar` (idle pill) / `.screenSaver` (above full-screen), `[.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]`, `hidesOnDeactivate = false`.
- Notch geometry: `NSScreen.safeAreaInsets.top` + `auxiliaryTopLeftArea`/`auxiliaryTopRightArea`; floating-pill fallback for external/notchless displays; re-frame on `didChangeScreenParameters`.
- Morph/state machine: `PhaseAnimator`/`KeyframeAnimator` for content; `NSAnimationContext` for panel-frame morphs; Metal/CALayer only for hero moments.
- Now-playing: AppleScript/JXA default (public), MediaRemote adapter as opt-in enhancement with automatic fallback.
- Hotkeys: Carbon via HotKey; clipboard: `changeCount` polling; drops: `.onDrop`.
- Distribution: Developer ID + notarization (not App Store) to start.

## Sources

GPUI window internals: [gpui_macos/window.rs](https://github.com/zed-industries/zed/blob/main/crates/gpui_macos/src/window.rs) · tray PR closed: [zed#13098](https://github.com/zed-industries/zed/pull/13098) · macOS tray in limbo: [zed#44047](https://github.com/zed-industries/zed/pull/44047) · background/tray discussion: [zed#40318](https://github.com/zed-industries/zed/discussions/40318) · floating-key bug: [zed#54017](https://github.com/zed-industries/zed/issues/54017) · GPUI paused: [HN](https://news.ycombinator.com/item?id=47003569) · fork analysis: [gpui ecosystem doc](https://github.com/intendednull/buiy/blob/main/docs/prior-art/gpui/ecosystem-and-comparisons.md) · references: [NotchApp](https://github.com/erwinzhang7/NotchApp), [DynamicNotch](https://github.com/jackson-storm/DynamicNotch), [boring.notch](https://github.com/TheBoredTeam/boring.notch), [Islet](https://github.com/MrRockySL/Islet), [mediaremote-adapter](https://github.com/ungive/mediaremote-adapter) · notarization ≠ private-API review: [9to5mac](https://9to5mac.com/2019/11/04/electron-app-rejections/).
