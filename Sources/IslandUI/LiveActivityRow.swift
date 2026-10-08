import DesignKit
import SwiftUI

/// Live-activity row (design-language §4): 37pt row, 13pt glyph, 12pt label,
/// 6pt content spacing, 24pt circular control.
public struct LiveActivityRow<Trailing: View>: View {
    private let systemImage: String
    private let title: String
    private let trailing: Trailing

    public init(
        systemImage: String,
        title: String,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.systemImage = systemImage
        self.title = title
        self.trailing = trailing()
    }

    public var body: some View {
        HStack(spacing: Metrics.LiveActivity.contentSpacing) {
            Image(systemName: systemImage)
                .font(.system(size: Metrics.LiveActivity.glyphSize, weight: .semibold))
                .foregroundStyle(IslandColor.textSecondary)
                .frame(width: Metrics.LiveActivity.controlDiameter)

            Text(title)
                .font(.system(size: Metrics.LiveActivity.labelSize, weight: .medium))
                .foregroundStyle(IslandColor.textPrimary)
                .lineLimit(1)

            Spacer(minLength: Metrics.LiveActivity.contentSpacing)

            trailing
        }
        .frame(height: Metrics.LiveActivity.rowHeight)
        .accessibilityElement(children: .combine)
    }
}

extension LiveActivityRow where Trailing == EmptyView {
    public init(systemImage: String, title: String) {
        self.init(systemImage: systemImage, title: title) { EmptyView() }
    }
}
