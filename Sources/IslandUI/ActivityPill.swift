import DesignKit
import SwiftUI

/// Wing pill beside the island (design-language §5: live-activity bubbles
/// stretch and merge — the pill is the compressed form of an activity).
public struct ActivityPill: View {
    private let systemImage: String
    private let label: String

    public init(systemImage: String, label: String) {
        self.systemImage = systemImage
        self.label = label
    }

    public var body: some View {
        HStack(spacing: Metrics.LiveActivity.contentSpacing / 2) {
            Image(systemName: systemImage)
                .font(.system(size: Metrics.LiveActivity.glyphSize, weight: .semibold))
            Text(label)
                .font(.system(size: Metrics.LiveActivity.labelSize, weight: .medium))
                .lineLimit(1)
        }
        .foregroundStyle(IslandColor.textPrimary)
        .padding(.horizontal, Metrics.LiveActivity.contentSpacing * 2)
        .frame(height: Metrics.LiveActivity.rowHeight)
        .background {
            Capsule(style: .continuous).fill(IslandColor.surfaceSecondary)
        }
        .accessibilityElement(children: .combine)
    }
}
