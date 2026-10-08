# Design language

The visual and motion system for top-drop-notch. **Every UI PR builds against these tokens.** Derived from research on Droppy's publicly documented design guidelines ([product-research.md §2](product-research.md)) and Apple's platform conventions — values here are *our* decisions.

## 1. Principles

1. **Black at the notch, melting into glass.** The surface starts as true black where it meets the hardware notch (or screen edge) and transitions outward into a glass/dark material. On notchless displays the island is full glass from the start.
2. **Flat, not glossy.** No borders, no outlines, no decorative gradients. Surfaces are separated by **fill contrast only**.
3. **Sentence case, always.** Never ALL-CAPS labels. No decorative dots inside chips.
4. **Continuous corners.** All radii use `.continuous` — a non-continuous corner next to ours reads visibly wrong.
5. **One spring.** Content animates on the shared app spring; individual views don't invent their own curves (a view animating on its own curve inside the host spring reads as lag).
6. **Interruptible motion.** Every open/close/morph can be interrupted mid-motion; state settles to the nearest valid end state.
7. **Reduce Motion is a first-class path.** Cross-fade or instant swaps instead of morphs; no motion artwork; no elastic overshoot. From commit #1, not polish phase.
8. **The surface never steals focus.** It is a non-activating panel; keyboard focus only moves when the user explicitly starts typing into it.

## 2. Geometry

Measured per display at runtime (see [architecture.md §Windows](architecture.md)):

| Constant | Value | Notes |
|---|---|---|
| Spacing grid | **4pt** | All spacing is a multiple of 4 unless a system value applies |
| Notch cutout height | `screen.safeAreaInsets.top` | Runtime, not hardcoded |
| Notch width | distance between `auxiliaryTopLeftArea` and `auxiliaryTopRightArea` | Runtime |
| Shoulders (closed state) | **32pt** horizontal fillets blending island → menu bar | Continuous corners |
| Shelf row top | cutout height + **10pt** below screen edge | Where content rows begin |
| Shelf horizontal inset | **48pt** from each opened shoulder | |
| Card inset from shell walls/floor | **17.5pt** | |
| Card corner radius | **18pt**, continuous | |
| Content inset against 18pt corner | **8pt** (0 for solo island cards, 0 in grouped rows) | |
| HUD card inset | cutout height top, 48pt sides | |
| Island padding | 16pt all round | |

**Camera-band avoidance:** on notched MacBooks, widget header rows lift into the two bands beside the camera (title in left band, control in right band, nothing over the housing). Header height **34pt**, minimum band width **64pt**. The host owns notch avoidance — content never pads around the notch itself.

**Notchless / external displays:** same features, rendered as a floating island pill at top-center (or user-set position), independent width/height/theming per display type, plus menu-bar integration.

## 3. Color tokens

Defined once (Swift `AdaptiveColors` equivalent), dark-mode native. No one-off colors in views.

| Token | Role |
|---|---|
| `surfacePrimary` | Main island/shell fill — starts at true black at the notch |
| `surfaceSecondary` | Secondary shell fill / glass edge |
| `surfaceTertiary` | Dimmed shell fill |
| `cardFill` | Card/content fill sitting on the shell (separated by contrast, never by stroke) |
| `textPrimary` | Primary label on surface |
| `textSecondary` | Secondary label |
| `textTertiary` | Captions/disabled |
| `accent` | User-selectable highlight (default system blue) |
| `sliderFill` | Accent-tinted slider fill (separate from accent if user overrides) |

User customization: highlight color, media text color, lock-screen text color, window tint (opaque backing for dark wallpapers), optional subtle outline.

## 4. Components

### Buttons ("flat wash")

- White wash fill (low-opacity), semibold glyph, **no** glass/hover/outline treatment.
- Press scale **0.94**.
- Diameters: **34pt** solo · **28pt** paired · **28pt** in a camera-wrapped row · **24pt** inline.
- Accent tone reserved for a widget's single primary action.

### Live-activity rows

| Metric | Value |
|---|---|
| Row height | 37pt |
| Glyph | 13pt |
| Label | 12pt |
| Content spacing | 6pt |
| Circular control | 24pt diameter |

### Cards

18pt continuous radius, `cardFill`, 8pt content inset. **No cards around notch widgets** — the shell's black is the background; cards are for HUDs and floating surfaces only.

### Settings

Unmodified macOS controls (grouped `Form`, bordered/borderedProminent buttons, native switches/pickers). Deliberately native — no custom glass in settings.

## 5. Motion

| Moment | Behavior |
|---|---|
| Island open/close | Shared spring, fast start (~2× open speed of close), **interruptible mid-motion**; auto-collapse delay after pointer leaves; hover-expand delay (per main/external display class) |
| Live-activity pills | Elastic stretch/merge as activities enter/leave — pills are one morphing shape, not separate views |
| Track swipe | Elastic horizontal stretch; settles on the shared spring |
| Player size morph | Continuous morph between sizes; edge "follows the finger" during drag, settles on release |
| Widget enter/leave | Fade + 4pt rise on shared spring |
| Drag jiggle | Low-amplitude continuous jiggle while dragging over a drop zone |
| Motion artwork | Runs only while media plays; static under Reduce Motion; cached per track (rasterize glow once) |

Global: `DroppyAnimation`-style presets (our `IslandAnimation`) — views take `\.animation` from environment, never hardcode `spring(response:)`.

## 6. Voice & copy

- Sentence case; short labels; no exclamation-mark enthusiasm.
- Errors state what happened + one next action. Never "Something went wrong" alone.

## 7. Accessibility (from commit #1)

- Every control: `accessibilityLabel` (+ `Value` where it reports state).
- Panel content: logical focus order; keyboard reachable; Esc closes expanded state.
- VoiceOver must announce island state changes (compact → expanded).
- Contrast: text tokens checked against their fills at 4.5:1 minimum.
- Reduce Motion / Increase Contrast / Differentiate Without Color respected (see §1.7).
