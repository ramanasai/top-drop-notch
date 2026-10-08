import SwiftUI

/// Color tokens — dark chrome, always (design-language §1–3).
/// Surfaces are separated by fill contrast only: no borders, no strokes, no gradients.
public enum IslandColor {
    /// True black where the island meets the hardware notch.
    public static let surfacePrimary = Color.black
    /// Secondary dark chrome (wings, pills) — reads beside black without a border.
    public static let surfaceSecondary = Color(white: 0.11)
    /// Tertiary fill for dimmed controls.
    public static let surfaceTertiary = Color(white: 0.18)
    /// Card fill sitting on the shell.
    public static let cardFill = Color.white.opacity(0.07)

    public static let textPrimary = Color.white
    public static let textSecondary = Color.white.opacity(0.70)
    public static let textTertiary = Color.white.opacity(0.40)

    /// Flat white wash behind wash buttons.
    public static let wash = Color.white.opacity(0.10)
    /// Wash fill while pressed.
    public static let washPressed = Color.white.opacity(0.17)

    /// Accent — user-configurable later; system accent for now.
    public static let accent = Color(nsColor: .controlAccentColor)
}
