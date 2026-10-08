import AppKit
import IslandUI
import WindowEngine

/// App entry: agent app (no Dock icon), attaches the island to the main screen.
/// Launch with `swift run` — see docs/development.md.
@main
struct TopDropNotchApp {
    static func main() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)

        guard let screen = NSScreen.main else {
            fputs("top-drop-notch: no screen available\n", stderr)
            exit(1)
        }

        let controller = IslandController(screen: screen)
        controller.attach(content: IslandRootView(controller: controller))
        controller.show()

        app.run()
    }
}
