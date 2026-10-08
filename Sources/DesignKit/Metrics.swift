import CoreGraphics

/// Design tokens — the single source of truth for layout constants.
/// Mirrors `docs/design-language.md`; UI code must reference these, never hardcode values.
public enum Metrics {
    /// The 4pt spacing grid. All spacing is a multiple of this unless a system value applies.
    public static let grid: CGFloat = 4

    // MARK: Notch / shelf geometry (design-language §2)

    /// Closed-state shoulder fillets blending the island into the menu bar strip.
    /// Assumption: hardware cutout height ≥ this value (true on all notched MacBooks).
    public static let shoulder: CGFloat = 32
    /// Where shelf content rows begin, measured below the cutout height from the screen top.
    public static let shelfTopOffset: CGFloat = 10
    /// Horizontal inset of the shelf row from each opened shoulder.
    public static let shelfSideInset: CGFloat = 48
    /// Card distance from the shell walls and floor.
    public static let cardInset: CGFloat = 17.5
    /// Content inset inside a card against its 18pt corner.
    public static let cardContentInset: CGFloat = 8
    /// Padding around expanded-island content.
    public static let islandPadding: CGFloat = 16
    /// HUD card horizontal inset from the screen edge (top inset = runtime cutout height).
    public static let hudSideInset: CGFloat = 48

    // MARK: Camera band avoidance (design-language §2)

    public enum CameraBand {
        /// Widget header rows lift into the two bands beside the camera.
        public static let headerHeight: CGFloat = 34
        /// Minimum usable width of a camera band.
        public static let minimumBandWidth: CGFloat = 64
    }

    // MARK: Buttons (design-language §4 — "flat wash")

    public enum Button {
        /// Press-scale applied to every wash button.
        public static let pressScale: CGFloat = 0.94

        /// Glyph sizes are our decision (docs specify diameters only); flagged for design review.
        public static func glyphSize(forDiameter diameter: CGFloat) -> CGFloat {
            switch diameter {
            case ..<26: return 12
            case ..<30: return 14
            default: return 16
            }
        }
    }

    // MARK: Live-activity rows (design-language §4)

    public enum LiveActivity {
        public static let rowHeight: CGFloat = 37
        public static let glyphSize: CGFloat = 13
        public static let labelSize: CGFloat = 12
        public static let contentSpacing: CGFloat = 6
        public static let controlDiameter: CGFloat = 24
    }

    // MARK: Corner radii (tiered, always `.continuous`)

    public enum Radius {
        /// Cards inside the island / HUD cards.
        public static let card: CGFloat = 18
        /// Expanded island shell — our decision, docs don't specify; adjust on design review.
        public static let island: CGFloat = 20
        /// Small inline surfaces (toasts, settings chips).
        public static let small: CGFloat = 10
    }

    // MARK: Notchless floating pill (design-language §2)

    public enum Pill {
        /// Default size of the floating island on notchless displays — our decision.
        public static let size = CGSize(width: 220, height: 36)
    }
}
