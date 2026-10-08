import DesignKit
import SwiftUI

/// Flat "wash" circular button (design-language §4): white wash, semibold glyph,
/// 0.94 press scale — no glass, no hover, no outline.
public struct WashButton: View {
    /// Diameter tiers from design-language §4.
    public enum Size {
        case solo      // 34pt
        case paired    // 28pt
        case inline    // 24pt

        var diameter: CGFloat {
            switch self {
            case .solo: 34
            case .paired: 28
            case .inline: 24
            }
        }
    }

    private let systemImage: String
    private let size: Size
    private let tint: Color
    private let action: () -> Void

    public init(
        systemImage: String,
        size: Size = .solo,
        tint: Color = IslandColor.textPrimary,
        action: @escaping () -> Void
    ) {
        self.systemImage = systemImage
        self.size = size
        self.tint = tint
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: Metrics.Button.glyphSize(forDiameter: size.diameter), weight: .semibold))
                .foregroundStyle(tint)
        }
        .buttonStyle(WashButtonStyle(diameter: size.diameter))
        .accessibilityLabel(Text(systemImage))
    }
}

private struct WashButtonStyle: ButtonStyle {
    let diameter: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: diameter, height: diameter)
            .background {
                Circle()
                    .fill(configuration.isPressed ? IslandColor.washPressed : IslandColor.wash)
            }
            .contentShape(Circle())
            .scaleEffect(configuration.isPressed ? Metrics.Button.pressScale : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
