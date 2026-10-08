# Agent skills for this project

Skills gathered for working on top-drop-notch. Installed via [`npx skills`](https://skills.sh) (global, `~/.agents/skills/`).

## Installed for this project

| Skill | Source | Use when |
|---|---|---|
| `swiftui-expert-skill` | avdlee/swiftui-agent-skill | Writing/reviewing SwiftUI: state + `@Observable` flow, composition, layouts, performance, API migration |
| `swiftui-pro` | twostraws/swiftui-agent-skill | Best-practice review pass over SwiftUI code (Paul Hudson's conventions) |
| `swiftui-animation` | dpearson2699/swift-ios-skills | Springs, `PhaseAnimator`, `KeyframeAnimator`, matched geometry, Reduce Motion — **the island morph work** |
| `macos-app-design` | petekp/agent-skills | Native macOS idioms: menu structure, shortcuts, windows, Liquid Glass, SF Symbols, "good Mac citizen" |
| `xcode-project-setup` | firebase/agent-skills | Safely editing `.pbxproj` / adding Swift packages — only if an Xcode project appears (M6 signing) |

Failed to install: `uizze.sh@ios-design` (source repo unreachable). Covered by built-ins below.

## Built-in skills already available (no install needed)

| Skill | Use when |
|---|---|
| `swiftui` | SwiftUI API reference (views, layout, navigation, `@State`/`@Binding`/`@Observable`) |
| `swift-concurrency` / `guide-swift-concurrency` | actors, `@MainActor`, structured concurrency for services |
| `swift-testing` / `guide-swift-testing` | `@Test`/`#expect` patterns for unit tests |
| `guide-macos-spm-packaging` | SwiftPM-based macOS app layout without an Xcode project — **matches our M1 scaffold exactly** |
| `ios-dev` | Navigation hub for Apple-platform work |
| `frontend-design` / `high-end-visual-design` / `taste-skill` | Aesthetic direction when designing island pages/empty states |
| `hig` | Apple HIG lookup: hit-target sizes, Dynamic Type, platform conventions |
| `xcuitest` | Only if UI tests are added later |
| `code-review` | Reviewing a branch/PR against repo standards + spec |
| `tdd` | Test-first workflow for model logic (tray retention, clipboard filters) |
| `diagnosing-bugs` | Hard-bug loop (e.g. windowing weirdness) |
| `find-skills` | Discovering more skills if a gap appears |

## Behavioral context

[AGENTS.md](../AGENTS.md) (Karpathy-inspired guidelines + project rules) applies to every agent session regardless of which skill is loaded.

## Maintenance

```bash
npx skills list        # what's installed
npx skills update      # update all
npx skills find <q>    # discover more (e.g. "macos menu bar", "notarization")
```

Review new skills before trusting them — they run with full agent permissions.
