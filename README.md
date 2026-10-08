# top-drop-notch

> **Working title / codename:** `top-drop-notch`
> A Dynamic-Island-style notch overlay for macOS — live activities, now playing, file tray, clipboard history, and a pluggable extension system, inspired by [Droppy](https://getdroppy.app/).

**Status: pre-alpha — component foundation landed.** Buildable SwiftPM skeleton (`swift build && swift test`) with design tokens, overlay window engine, and reusable island components. Remaining milestones live in [TODO.md](TODO.md). Product/technical decisions are in [`docs/`](docs/).

## What this is

A native macOS agent app (`LSUIElement`) that renders an overlay anchored to the MacBook notch (or a floating island on notchless displays) and turns it into a small productivity surface:

- **Island + Now Playing** — hover-to-expand notch with media controls and artwork.
- **Live Activities** — transient pills beside the island (volume/brightness HUDs, timers, recording state).
- **File tray** — drag files onto the notch, hold them, act on them.
- **Clipboard history** — searchable history one shortcut away.
- **Extension system** — features shipped as toggleable in-process modules ("droplets"-style).

Minimum target: **macOS 14 Sonoma**.

## Stack decision

**Swift + SwiftUI (content) + AppKit (windows/system integration).** GPUI/Rust was evaluated and rejected — see [ADR-0001](docs/adr/0001-use-swift-swiftui-appkit.md) and [docs/architecture.md](docs/architecture.md) for the full comparison.

## Build & test

```bash
swift build   # build all targets
swift test    # unit tests (geometry, state machine)
swift run     # launch the island (agent app — no Dock icon; Ctrl+C to quit)
```

## Repository workflow (enforced)

- **`main` is protected.** Nothing merges to `main` directly — every change lands via a pull request.
- Work on a feature branch: `feat/…`, `fix/…`, `docs/…`, `chore/…`.
- Use **[Conventional Commits](https://www.conventionalcommits.org)** — the changelog is generated from them.
- Changelog is generated with **[git-cliff](https://git-cliff.org)** from `cliff.toml` into `CHANGELOG.md`.

```bash
# regenerate changelog (maintainers, on the release branch/PR)
git-cliff -o CHANGELOG.md

# preview without writing
git-cliff --context > /dev/null   # config validation (also runs in CI)
```

## Documentation

| Doc | Purpose |
|---|---|
| [docs/README.md](docs/README.md) | Documentation index |
| [docs/product-research.md](docs/product-research.md) | Deep research on Droppy (the inspiration product) |
| [docs/competitive-landscape.md](docs/competitive-landscape.md) | Notch-app competitor matrix |
| [docs/design-language.md](docs/design-language.md) | Visual design system (tokens, motion, geometry) |
| [docs/architecture.md](docs/architecture.md) | Technical architecture & module layout |
| [docs/adr/0001-use-swift-swiftui-appkit.md](docs/adr/0001-use-swift-swiftui-appkit.md) | Why Swift/SwiftUI over GPUI |
| [docs/roadmap.md](docs/roadmap.md) | Milestones M0 → M6 with exit criteria |
| [TODO.md](TODO.md) | In-depth, phase-by-phase to-do list |
| [docs/development.md](docs/development.md) | Branching, commits, git-cliff, releases |
| [docs/permissions.md](docs/permissions.md) | macOS permission matrix (what/when/why) |
| [docs/skills.md](docs/skills.md) | Agent skills gathered for this project |

## Agent instructions

This project is agent-assisted. Behavioral rules for all agents live in [AGENTS.md](AGENTS.md) (Karpathy-inspired guidelines + project-specific rules). `CLAUDE.md` points there.

## License

[MIT](LICENSE) — chosen for the scaffold; revisit before any public launch if a different license is preferred.
