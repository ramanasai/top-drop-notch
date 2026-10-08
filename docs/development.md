# Development guide

How to work in this repo. Behavioral rules: [AGENTS.md](../AGENTS.md). Architecture: [architecture.md](architecture.md).

## Prerequisites

- macOS 14+ (development on 14/15/26 all fine — min target is 14)
- Xcode 16+ or CLT with Swift 5.9+ (`swift --version`)
- [git-cliff](https://git-cliff.org) (`brew install git-cliff`) — changelog generation
- GitHub CLI (`gh`) — PRs, releases

## Build & test

```bash
swift build          # build all targets
swift test            # run unit tests
swift run             # launch the app locally (agent app — no Dock icon)
```

There is deliberately **no Xcode project** yet (see [architecture §7](architecture.md)); SwiftPM is the source of truth. An `.xcodeproj`/`xcworkspace` may be introduced at M6 for signing — never commit `xcuserdata`.

Open in Xcode with `open Package.swift` for interactive work.

## Branching — hard rules

1. **Nothing merges or pushes directly to `main`.** Branch protection enforces it.
2. Branch from `main`, one unit of work per branch:
   - `feat/<name>` · `fix/<name>` · `docs/<name>` · `chore/<name>` · `refactor/<name>` · `test/<name>`
3. Keep PRs small and single-purpose; every changed line traces to the request.
4. Update the docs (and [TODO.md](../TODO.md) checkboxes) in the same PR as the behavior they describe.

## Commits — Conventional Commits

```
<type>(<scope>): <imperative summary>

[body: why, not what]
```

- Types: `feat` `fix` `docs` `chore` `refactor` `perf` `test` `style` `ci` `revert`
- Scope vocabulary (use only these; extend `cliff.toml` + AGENTS.md together if new ones are needed):
  `island` · `activity` · `tray` · `clipboard` · `media` · `settings` · `ext` · `window` · `ci` · `docs` · `release`
- One logical change per commit. No `wip`, no `fix stuff`.

Examples:

```
feat(window): add non-activating island panel with click-through
fix(geometry): treat zero-width auxiliary bands as notchless
docs(design): define shared spring presets
```

## Changelog — git-cliff

- `CHANGELOG.md` is **generated from commit messages** — never hand-edit it.
- Regenerate and commit inside your PR when changes are user-visible:

  ```bash
  git-cliff -o CHANGELOG.md
  ```

- Config lives in [`cliff.toml`](../cliff.toml). New commit types/scopes → update parsers in the same PR.
- CI validates the config (`git-cliff --context`) so a broken `cliff.toml` can't merge.

## Pull requests

- Use the PR template; link the issue or TODO item.
- Before requesting review:
  - [ ] `swift build && swift test` pass
  - [ ] design tokens followed ([design-language.md](design-language.md)) — no one-off colors/radii/springs
  - [ ] permissions documented ([permissions.md](permissions.md)) if new APIs touched
  - [ ] `git-cliff -o CHANGELOG.md` regenerated if user-visible
  - [ ] manual test matrix for anything touching windows: notched, external display, full-screen, Reduce Motion
- Squash or merge-commit both fine — the PR title must be a valid Conventional Commit (it becomes the changelog entry on squash).

## CI

`.github/workflows/ci.yml` runs on every PR and push to `main`:

1. **build-test** (macOS runner): `swift build && swift test` — starts at M1 when `Package.swift` exists (auto-skips until then).
2. **changelog**: validates `cliff.toml` via `git-cliff --context`.

## Releases (M6 — documented early so the flow is familiar)

```bash
git-cliff --tag v0.1.0 -o CHANGELOG.md   # 1. generate with tag
# 2. commit via PR → merge → tag on main: git tag v0.1.0 && git push origin v0.1.0
# 3. CI/release script: codesign → notarize → staple → GitHub Release with artifact
```

Signing identities, API keys, and provisioning profiles **never** enter the repo (see `.gitignore`).

## Style

- Swift 5.9+, `swift format` conventions as found in surrounding files (match existing style over personal preference).
- SwiftUI for content/views; AppKit only for what SwiftUI can't do (panels, status item, drag sessions, screen metrics).
- All values from tokens ([design-language.md](design-language.md)) — if you need a new constant, add it to `DesignKit` in the same PR.
- `@MainActor` for anything touching UI or AppKit; services as actors when state is shared.
- Accessibility labels and Reduce Motion handling are part of "done", not polish.
