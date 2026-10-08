// swift-tools-version:5.9
import PackageDescription

// TopDropNotch — macOS 14+ notch overlay app.
// Layering (no cycles): DesignKit ← WindowEngine ← IslandUI ← executable.
let package = Package(
    name: "TopDropNotch",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        // Design tokens: metrics, colors, motion presets. No dependencies.
        .target(name: "DesignKit"),

        // Windowing + state: notch geometry, overlay panel, island state machine, controller.
        .target(
            name: "WindowEngine",
            dependencies: ["DesignKit"]
        ),

        // Reusable SwiftUI components composed from DesignKit tokens.
        .target(
            name: "IslandUI",
            dependencies: ["DesignKit", "WindowEngine"]
        ),

        // Executable: wires controller + root view, runs the agent app.
        .executableTarget(
            name: "TopDropNotch",
            dependencies: ["DesignKit", "WindowEngine", "IslandUI"]
        ),

        .testTarget(
            name: "WindowEngineTests",
            dependencies: ["WindowEngine", "DesignKit"]
        ),
    ]
)
