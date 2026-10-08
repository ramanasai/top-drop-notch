# Documentation index

Everything about *why* and *what* for top-drop-notch lives here. Behavioral rules for agents live in [../AGENTS.md](../AGENTS.md); the phase-by-phase checklist lives in [../TODO.md](../TODO.md).

## Product

| Doc | What it answers |
|---|---|
| [product-research.md](product-research.md) | Deep research on Droppy — features, design language, interactions, permissions, architecture hints |
| [competitive-landscape.md](competitive-landscape.md) | Who else ships a notch app, at what price, with what gaps |
| [design-language.md](design-language.md) | The visual/motion system we build against (tokens, geometry, buttons, animation rules) |

## Technical

| Doc | What it answers |
|---|---|
| [architecture.md](architecture.md) | Module layout, window strategy, data flow, extension model |
| [adr/0001-use-swift-swiftui-appkit.md](adr/0001-use-swift-swiftui-appkit.md) | Why Swift+SwiftUI/AppKit instead of GPUI/Rust (full comparison) |
| [permissions.md](permissions.md) | Every macOS permission: what needs it, when to ask, fallback behavior |
| [development.md](development.md) | Branching, conventional commits, git-cliff changelog, release flow |

## Planning

| Doc | What it answers |
|---|---|
| [roadmap.md](roadmap.md) | Milestones M0→M6 with exit criteria and cut lines |
| [../TODO.md](../TODO.md) | The in-depth, checkbox to-do list derived from the roadmap |
| [skills.md](skills.md) | Agent skills installed for this project and when to use them |

## Conventions for docs

- Docs are decisions. If a doc and the code disagree, the PR that changed behavior must update the doc.
- Prefer links over duplication; when repeating, keep one canonical section and link.
- Research docs ([product-research.md](product-research.md), [competitive-landscape.md](competitive-landscape.md)) are dated snapshots — add a "last reviewed" date when editing.
