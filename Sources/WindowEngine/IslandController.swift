import AppKit
import DesignKit
import SwiftUI

/// Owns the island panel, geometry, and state machine.
/// Translates `IslandEvent`s into state + panel-frame morphs.
///
/// The SwiftUI content is attached by the app layer (`NSHostingView` set as
/// `panel.contentView` via `attach(content:)`) — WindowEngine never imports
/// IslandUI, so IslandUI can depend on it without a cycle (architecture §1–3).
@MainActor
public final class IslandController: ObservableObject {
    @Published public private(set) var state: IslandState = .closed
    @Published public private(set) var geometry: NotchGeometry

    public let panel: IslandPanel
    private var screenObserver: Any?
    private let reduceMotion: Bool

    /// Content size for the expanded state; call after the view reports its ideal size.
    public var expandedSize: CGSize = CGSize(width: 360, height: 200) {
        didSet { if case .expanded = state { applyFrame(animated: false) } }
    }

    public init(screen: NSScreen) {
        let geometry = Self.geometry(for: screen)
        self.geometry = geometry
        self.reduceMotion = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        self.panel = IslandPanel(geometry: geometry)

        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.recomputeGeometry() }
        }
    }

    deinit {
        if let screenObserver { NotificationCenter.default.removeObserver(screenObserver) }
    }

    // MARK: - Events

    public func handle(_ event: IslandEvent) {
        let next = state.applying(event)
        guard next != state else { return }
        state = next
        applyFrame(animated: true)
    }

    public func show() {
        panel.setFrame(frame(for: state), display: false)
        panel.orderFrontRegardless()
    }

    /// Install SwiftUI content as the panel's content view (called by the app layer).
    public func attach<Content: View>(content: Content) {
        let hosting = NSHostingView(rootView: content)
        hosting.frame = NSRect(origin: .zero, size: panel.frame.size)
        hosting.autoresizingMask = [.width, .height]
        panel.contentView = hosting
    }

    // MARK: - Geometry

    private func recomputeGeometry() {
        guard let screen = NSScreen.main else { return }
        geometry = Self.geometry(for: screen)
        applyFrame(animated: false)
    }

    private func applyFrame(animated: Bool) {
        let target = frame(for: state)
        if animated {
            panel.morph(to: target, reduceMotion: reduceMotion)
        } else {
            panel.setFrame(target, display: true)
        }
    }

    private func frame(for state: IslandState) -> CGRect {
        switch state {
        case .closed, .acceptingDrop:
            return geometry.closedFrame()
        case .expanded:
            return geometry.expandedFrame(contentSize: expandedSize)
        }
    }

    private static func geometry(for screen: NSScreen) -> NotchGeometry {
        NotchGeometry(
            screenFrame: screen.frame,
            cutoutHeight: screen.safeAreaInsets.top,
            cutoutWidth: cutoutWidth(of: screen)
        )
    }

    /// Width between the two menu-bar bands flanking the camera housing (0 if no notch).
    private static func cutoutWidth(of screen: NSScreen) -> CGFloat {
        guard let left = screen.auxiliaryTopLeftArea,
              let right = screen.auxiliaryTopRightArea,
              screen.safeAreaInsets.top > 0
        else { return 0 }
        return max(0, right.minX - left.maxX)
    }
}
