import DesignKit
import SwiftUI

/// Widget header that lifts into the two camera bands (design-language §2):
/// title in the left band, control in the right band, nothing over the housing.
/// The host handles notch avoidance — content never pads around the notch itself.
public struct CameraBandHeader: View {
    private let title: String
    private let control: AnyView?

    public init(title: String, control: AnyView? = nil) {
        self.title = title
        self.control = control
    }

    public var body: some View {
        HStack {
            Text(title)
                .font(.system(size: Metrics.LiveActivity.labelSize, weight: .semibold))
                .foregroundStyle(IslandColor.textSecondary)

            Spacer()

            if let control { control }
        }
        .frame(height: Metrics.CameraBand.headerHeight)
        .accessibilityElement(children: .combine)
    }
}
