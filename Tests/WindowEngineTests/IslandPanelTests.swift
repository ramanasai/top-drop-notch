import XCTest
@testable import WindowEngine
import CoreGraphics

/// Regression: the island deployed below the menu bar (y = menuBarHeight instead of y = 0)
/// because `isFloatingPanel = true` was assigned AFTER `level = .screenSaver`, resetting
/// the window to .floating (CG layer 3 — below the menu bar, level 24), so the window
/// server clamped it under the menu bar. Observed 2026-10-08 on a notched MacBook
/// (safeArea top = 32pt, menu bar gap = 33pt).
final class IslandPanelTests: XCTestCase {
    func testPanelFrameIsNotClampedBelowTheMenuBar() {
        let screen = CGRect(x: 0, y: 0, width: 1512, height: 982)
        let geometry = NotchGeometry(screenFrame: screen, cutoutHeight: 32, cutoutWidth: 185)
        let target = geometry.closedFrame()
        XCTAssertEqual(target.maxY, screen.maxY, accuracy: 0.001, "fixture: closed frame touches screen top")

        let panel = IslandPanel(geometry: geometry)
        defer { panel.close() }

        // Regression: `isFloatingPanel = true` used to be set AFTER `level`, resetting it
        // to .floating (CG layer 3 — below the menu bar) and getting the island clamped
        // under the menu bar in the deployed app (2026-10-08).
        XCTAssertEqual(panel.level, .screenSaver, "level must be set after isFloatingPanel")

        panel.setFrame(target, display: false)
        XCTAssertEqual(
            panel.frame.maxY, target.maxY, accuracy: 0.5,
            "panel top edge must stay flush with the screen top (not pushed below the menu bar)"
        )
        XCTAssertEqual(panel.frame.width, target.width, accuracy: 0.5)
        XCTAssertEqual(panel.frame.height, target.height, accuracy: 0.5)
    }
}
