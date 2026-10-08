import CoreGraphics
import DesignKit

/// Notch geometry for one display, computed from screen metrics.
/// Pure and testable: no NSScreen dependency — feed it raw values.
public struct NotchGeometry: Equatable, Sendable {
    /// Screen bounds in AppKit coordinates (origin bottom-left).
    public let screenFrame: CGRect
    /// Hardware cutout height measured down from the top edge (0 on notchless displays).
    public let cutoutHeight: CGFloat
    /// Distance between the inner edges of the menu-bar bands flanking the camera housing.
    /// Zero-width ⇒ notchless display.
    public let cutoutWidth: CGFloat

    public var isHardwareNotch: Bool { cutoutWidth > 0 && cutoutHeight > 0 }

    public init(screenFrame: CGRect, cutoutHeight: CGFloat, cutoutWidth: CGFloat) {
        self.screenFrame = screenFrame
        self.cutoutHeight = max(0, cutoutHeight)
        self.cutoutWidth = max(0, cutoutWidth)
    }

    // MARK: - Frames

    /// Top edge of the screen (AppKit coords).
    public var screenTop: CGFloat { screenFrame.maxY }

    /// Closed state: hugs the hardware cutout, shoulders extending to each side.
    /// Notchless: centered floating pill at the top edge.
    public func closedFrame(shoulder: CGFloat = Metrics.shoulder) -> CGRect {
        guard isHardwareNotch else {
            let w = Metrics.Pill.size.width, h = Metrics.Pill.size.height
            return CGRect(
                x: screenFrame.midX - w / 2,
                y: screenTop - h,
                width: w,
                height: h
            )
        }
        let w = cutoutWidth + shoulder * 2
        return CGRect(
            x: screenFrame.midX - w / 2,
            y: screenTop - cutoutHeight,
            width: w,
            height: cutoutHeight
        )
    }

    /// Expanded island frame for a given content size, anchored to the top edge.
    /// Notchless: anchored to the pill's horizontal center.
    public func expandedFrame(contentSize: CGSize) -> CGRect {
        let origin: CGRect = closedFrame()
        return CGRect(
            x: origin.midX - contentSize.width / 2,
            y: screenTop - contentSize.height,
            width: contentSize.width,
            height: contentSize.height
        )
    }

    /// The two camera bands flanking the housing: (left, right) in AppKit coords.
    /// On notchless displays both are zero-width rects at the horizontal center.
    public func cameraBands(shoulder: CGFloat = Metrics.shoulder) -> (left: CGRect, right: CGRect) {
        guard isHardwareNotch else {
            let zero = CGRect(x: screenFrame.midX, y: screenTop, width: 0, height: 0)
            return (zero, zero)
        }
        let bandHeight = cutoutHeight
        let left = CGRect(
            x: screenFrame.midX - cutoutWidth / 2 - shoulder - Metrics.CameraBand.minimumBandWidth,
            y: screenTop - bandHeight,
            width: Metrics.CameraBand.minimumBandWidth,
            height: bandHeight
        )
        let right = CGRect(
            x: screenFrame.midX + cutoutWidth / 2 + shoulder,
            y: screenTop - bandHeight,
            width: Metrics.CameraBand.minimumBandWidth,
            height: bandHeight
        )
        return (left, right)
    }
}
