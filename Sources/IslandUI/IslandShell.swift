import DesignKit
import SwiftUI

/// The island's shell surface: true black at the notch, continuous corners,
/// no borders — separation by fill contrast only (design-language §1–3).
public struct IslandShell<Content: View>: View {
    private let cornerRadius: CGFloat
    private let content: Content

    public init(
        cornerRadius: CGFloat = Metrics.Radius.island,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    public var body: some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(IslandColor.surfacePrimary)
            }
    }
}
