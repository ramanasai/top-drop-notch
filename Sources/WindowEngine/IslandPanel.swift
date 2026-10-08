import AppKit
import DesignKit

/// The borderless, non-activating overlay panel that hosts the island.
///
/// Setup per architecture §2:
/// - never takes focus (non-activating, `canBecomeKey/Main = false`)
/// - floats above menu bar and full-screen apps (`.screenSaver` level)
/// - visible on every space, never hidden by Mission Control
/// - sized to the island content only, so everything outside it is naturally click-through
public final class IslandPanel: NSPanel {
    public override var canBecomeKey: Bool { false }
    public override var canBecomeMain: Bool { false }

    public init(geometry: NotchGeometry) {
        super.init(
            contentRect: geometry.closedFrame(),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        isFloatingPanel = true
        hidesOnDeactivate = false
        becomesKeyOnlyIfNeeded = false
        isMovable = false
        isReleasedWhenClosed = false
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false // island draws its own continuous shoulders
        animationBehavior = .none // frame morphs are driven explicitly (IslandController)
        // Must be set LAST: assigning `isFloatingPanel = true` resets the level to
        // .floating (observed: CG layer 3, below the menu bar, window clamped under it).
        level = .screenSaver
    }

    /// Move/resize to `frame`, animating the morph through AppKit so the window
    /// and the SwiftUI content share one timeline.
    public func morph(to frame: CGRect, reduceMotion: Bool) {
        let duration = reduceMotion
            ? IslandAnimation.reducedFrameMorphDuration
            : IslandAnimation.frameMorphDuration
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animator().setFrame(frame, display: true)
        })
    }
}
