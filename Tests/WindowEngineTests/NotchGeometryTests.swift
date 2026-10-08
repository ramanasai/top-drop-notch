import XCTest
@testable import WindowEngine
import CoreGraphics
import DesignKit

final class NotchGeometryTests: XCTestCase {
    // Fixture: 14" MacBook Pro-ish screen (1512×982pt), hardware notch 37.5pt tall, 200pt wide.
    private let notchedScreen = CGRect(x: 0, y: 0, width: 1512, height: 982)
    private func notched(cutoutHeight: CGFloat = 37.5, cutoutWidth: CGFloat = 200) -> NotchGeometry {
        NotchGeometry(screenFrame: notchedScreen, cutoutHeight: cutoutHeight, cutoutWidth: cutoutWidth)
    }

    // Fixture: external 4K display, no notch.
    private let notchlessScreen = CGRect(x: 1512, y: 100, width: 3840, height: 2160)
    private func notchless() -> NotchGeometry {
        NotchGeometry(screenFrame: notchlessScreen, cutoutHeight: 0, cutoutWidth: 0)
    }

    // MARK: Notch detection

    func testNotchedDisplayIsDetected() {
        XCTAssertTrue(notched().isHardwareNotch)
    }

    func testNotchlessDisplayIsDetected() {
        XCTAssertFalse(notchless().isHardwareNotch)
    }

    func testZeroHeightWithWidthIsNotANotch() {
        XCTAssertFalse(notched(cutoutHeight: 0).isHardwareNotch)
    }

    func testNegativeValuesAreClamped() {
        let geometry = NotchGeometry(screenFrame: notchedScreen, cutoutHeight: -5, cutoutWidth: -10)
        XCTAssertEqual(geometry.cutoutHeight, 0)
        XCTAssertEqual(geometry.cutoutWidth, 0)
        XCTAssertFalse(geometry.isHardwareNotch)
    }

    // MARK: Closed frame

    func testClosedFrameHugsTheCutout() {
        let frame = notched().closedFrame()
        XCTAssertEqual(frame.height, 37.5, accuracy: 0.001)
        XCTAssertEqual(frame.width, 200 + Metrics.shoulder * 2, accuracy: 0.001)
        // Top of the frame sits at the top edge of the screen.
        XCTAssertEqual(frame.maxY, notchedScreen.maxY, accuracy: 0.001)
        // Horizontally centered.
        XCTAssertEqual(frame.midX, notchedScreen.midX, accuracy: 0.001)
    }

    func testClosedFrameOnNotchlessIsCenteredPillAtTopEdge() {
        let frame = notchless().closedFrame()
        XCTAssertEqual(frame.size, Metrics.Pill.size)
        XCTAssertEqual(frame.midX, notchlessScreen.midX, accuracy: 0.001)
        XCTAssertEqual(frame.maxY, notchlessScreen.maxY, accuracy: 0.001)
    }

    // MARK: Expanded frame

    func testExpandedFrameIsAnchoredToTopEdgeAndCentered() {
        let content = CGSize(width: 360, height: 240)
        let frame = notched().expandedFrame(contentSize: content)
        XCTAssertEqual(frame.size, content)
        XCTAssertEqual(frame.maxY, notchedScreen.maxY, accuracy: 0.001)
        XCTAssertEqual(frame.midX, notchedScreen.midX, accuracy: 0.001)
    }

    func testExpandedFrameOnSecondDisplayUsesItsCoordinates() {
        // Regression: geometry for external screens must use the screen's own origin.
        let content = CGSize(width: 300, height: 200)
        let frame = notchless().expandedFrame(contentSize: content)
        XCTAssertEqual(frame.midX, notchlessScreen.midX, accuracy: 0.001)
        XCTAssertEqual(frame.maxY, notchlessScreen.maxY, accuracy: 0.001)
        XCTAssertGreaterThan(frame.minX, notchedScreen.maxY, "must not fall back to primary-screen coords")
    }

    // MARK: Camera bands

    func testCameraBandsFlankTheHousing() {
        let bands = notched().cameraBands()
        // Left band ends where the cutout + shoulder begins; right band starts symmetrically.
        XCTAssertLessThan(bands.left.maxX, notchedScreen.midX)
        XCTAssertGreaterThan(bands.right.minX, notchedScreen.midX)
        XCTAssertEqual(bands.left.width, Metrics.CameraBand.minimumBandWidth, accuracy: 0.001)
        XCTAssertEqual(bands.right.width, Metrics.CameraBand.minimumBandWidth, accuracy: 0.001)
    }

    func testCameraBandsAreZeroOnNotchlessDisplays() {
        let bands = notchless().cameraBands()
        XCTAssertEqual(bands.left.width, 0)
        XCTAssertEqual(bands.right.width, 0)
    }
}
