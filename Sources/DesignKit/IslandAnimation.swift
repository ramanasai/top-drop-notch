import SwiftUI

/// Motion presets — "One spring" (design-language §5).
/// Views must use these presets instead of inventing curves; a component animating on its
/// own curve inside the host spring reads as lag.
public enum IslandAnimation {
    /// The shared content spring: snappy, interruptible, minimal overshoot.
    public static let spring = Animation.spring(response: 0.35, dampingFraction: 0.82)

    /// Island open — starts fast (docs: open ≈ 2× close speed).
    public static let open = Animation.spring(response: 0.28, dampingFraction: 0.86)

    /// Island close / settle.
    public static let close = Animation.spring(response: 0.45, dampingFraction: 0.88)

    /// Reduce Motion path: cross-fade, no morph, no overshoot (design-language §1.7).
    public static let reduced = Animation.easeInOut(duration: 0.15)

    /// Resolve the appropriate preset honoring Reduce Motion.
    public static func preferred(reduceMotion: Bool) -> Animation {
        reduceMotion ? reduced : spring
    }

    /// AppKit-side frame-morph duration paired with `open`/`close`
    /// (`NSAnimationContext` can't run SwiftUI springs; M1 does exact timeline sync).
    public static let frameMorphDuration: TimeInterval = 0.30
    /// Reduce Motion frame morph: effectively instant.
    public static let reducedFrameMorphDuration: TimeInterval = 0.001
}
