# AGENTS.md

Behavioral guidelines for AI coding agents working in this repository, plus project-specific rules.
Based on the [Karpathy-inspired guidelines](https://github.com/forrestchang/andrej-karpathy-skills) by Forrest Chang (MIT), itself derived from Andrej Karpathy's January 2026 post on LLM coding failure modes.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## Part 1 — Behavioral guidelines

### 1. Think before coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity first

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

### 3. Surgical changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: every changed line should trace directly to the user's request.

### 4. Goal-driven execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

## Part 2 — Project rules (top-drop-notch)

### Branching & merging — hard rules

1. **Never merge or push directly to `main`.** `main` is branch-protected; every change goes through a pull request.
2. Create a branch from `main` for every unit of work: `feat/<short-name>`, `fix/<short-name>`, `docs/<short-name>`, `chore/<short-name>`, `refactor/<short-name>`.
3. Keep PRs small and single-purpose. A PR should trace to one request or one issue.
4. Before opening a PR: build passes, tests pass, `git-cliff` changelog regenerated if commits affect release notes.

### Commits

- **[Conventional Commits](https://www.conventionalcommits.org)** exactly: `feat(island): expand on hover with interruptible spring`, `fix(tray): retain pinned files after cleanup`.
- Scope vocabulary (keep consistent): `island`, `activity`, `tray`, `clipboard`, `media`, `settings`, `ext`, `window`, `ci`, `docs`, `release`.
- One logical change per commit. No "wip", no "fix stuff" on PRs destined for `main`.

### Changelog (git-cliff)

- `CHANGELOG.md` is **generated** — never hand-edit it.
- Regenerate with `git-cliff -o CHANGELOG.md` and commit it as part of the PR/release.
- New commit types or scopes → update `cliff.toml` parsers in the same PR.

### Code style & scope

- Swift 5.9+ / SwiftUI for content, AppKit only where SwiftUI can't do it (windowing, panels, status item, drag sessions).
- Match surrounding style. Follow the design tokens in [docs/design-language.md](docs/design-language.md) — no one-off colors, radii, or springs.
- Respect Reduce Motion and accessibility labels from the first commit; they are not polish-phase items.
- Private/fragile APIs (e.g. MediaRemote) are **opt-in with automatic fallback**, never the only path — see [docs/permissions.md](docs/permissions.md).
- Don't commit: `.DS_Store`, `xcuserdata/`, derived data, signing identities, licenses/keys.

### Before you start

- Read the relevant doc first (architecture, design language, roadmap item) and the TODO entry you're implementing.
- If the task doesn't match any TODO item or doc, ask — don't invent scope.
