import AppKit
import DesignKit
import SwiftUI
import WindowEngine

/// Root island view: renders the current `IslandState` inside the panel.
/// All events flow up through `onEvent` — the controller owns transitions.
public struct IslandRootView: View {
    @ObservedObject var controller: IslandController
    private let reduceMotion: Bool

    public init(controller: IslandController) {
        self.controller = controller
        self.reduceMotion = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
    }

    public var body: some View {
        Group {
            switch controller.state {
            case .closed:
                closedView
                    .transition(reduceMotion ? .opacity : .move(edge: .top))
            case .expanded(let page):
                expandedView(page: page)
                    .transition(reduceMotion ? .opacity : .move(edge: .top))
            case .acceptingDrop:
                acceptingDropView
                    .transition(.opacity)
            }
        }
        .animation(IslandAnimation.preferred(reduceMotion: reduceMotion), value: controller.state)
        .onHover { hovering in
            controller.handle(hovering ? .hoverEntered : .hoverExited)
        }
    }

    // MARK: - States

    private var closedView: some View {
        IslandShell {
            HStack(spacing: Metrics.grid * 2) {
                // Placeholder: mini artwork slot lands with M2 (Now Playing).
                Circle()
                    .fill(IslandColor.surfaceTertiary)
                    .frame(width: 18, height: 18)
            }
            .padding(.horizontal, Metrics.islandPadding / 2)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onTapGesture { controller.handle(.toggle) }
        .accessibilityLabel("Island collapsed")
    }

    private func expandedView(page: IslandPage) -> some View {
        IslandShell {
            VStack(spacing: Metrics.grid * 2) {
                CameraBandHeader(
                    title: title(for: page),
                    control: AnyView(
                        WashButton(systemImage: "chevron.up", size: .inline) {
                            controller.handle(.toggle)
                        }
                    )
                )

                // Placeholder content until M2 (player) / M3 (tray) / M2 (widgets grid).
                IslandCard {
                    HStack(spacing: Metrics.LiveActivity.contentSpacing) {
                        Image(systemName: "music.note")
                            .font(.system(size: Metrics.LiveActivity.glyphSize, weight: .semibold))
                            .foregroundStyle(IslandColor.textSecondary)
                        Text("Nothing playing")
                            .font(.system(size: Metrics.LiveActivity.labelSize))
                            .foregroundStyle(IslandColor.textTertiary)
                        Spacer()
                    }
                    .frame(height: Metrics.LiveActivity.rowHeight)
                }
            }
            .padding(Metrics.islandPadding)
        }
        .onTapGesture {} // expanded surface swallows taps (clicks outside don't reach it anyway)
    }

    private var acceptingDropView: some View {
        IslandShell(cornerRadius: Metrics.Radius.island) {
            HStack(spacing: Metrics.LiveActivity.contentSpacing) {
                Image(systemName: "arrow.down.doc")
                    .font(.system(size: Metrics.LiveActivity.glyphSize, weight: .semibold))
                Text("Drop files here")
                    .font(.system(size: Metrics.LiveActivity.labelSize, weight: .medium))
            }
            .foregroundStyle(IslandColor.textPrimary)
            .padding(Metrics.islandPadding)
            .frame(maxWidth: .infinity)
        }
    }

    private func title(for page: IslandPage) -> String {
        switch page {
        case .home: "Island"
        case .tray: "Tray"
        case .widgets: "Widgets"
        }
    }
}
