import DesignKit
import SwiftUI

/// Card inside the island / HUD surfaces (design-language §4):
/// 18pt continuous radius, `cardFill`, 8pt content inset — fill contrast, never a stroke.
public struct IslandCard<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(Metrics.cardContentInset)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: Metrics.Radius.card, style: .continuous)
                    .fill(IslandColor.cardFill)
            }
    }
}
