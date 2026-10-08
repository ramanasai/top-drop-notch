/// Island presentation states (architecture §3).
///
/// ```
///        hover/intent              dismiss/delay
/// compact ───────────▶ expanded ────────────────▶ compact
///    │                    │
///    │ drag file over     │ page swipe (home / tray / widgets)
///    ▼                    ▼
/// acceptingDrop        expanded(page)
/// ```
public enum IslandState: Equatable, Sendable {
    case closed
    case expanded(page: IslandPage)
    case acceptingDrop
}

/// Pages inside the expanded island.
public enum IslandPage: String, CaseIterable, Sendable {
    case home
    case tray
    case widgets
}

/// Events driving the state machine. Transitions are pure functions — unit tested.
public enum IslandEvent: Equatable, Sendable {
    case hoverEntered
    case hoverExited
    case toggle
    case dragEntered
    case dragExited
    case showPage(IslandPage)
    case dismiss
}

extension IslandState {
    /// Pure transition. Animation/interruptibility is the view layer's job;
    /// this only decides the resulting state.
    public func applying(_ event: IslandEvent) -> IslandState {
        switch (self, event) {
        case (_, .dismiss):
            return .closed
        case (.closed, .hoverEntered), (.closed, .toggle):
            return .expanded(page: .home)
        case (.closed, .dragEntered):
            return .acceptingDrop
        case (.acceptingDrop, .dragExited):
            return .closed
        case (.acceptingDrop, .hoverExited):
            return self // drag sessions own the island until the drag ends
        case (.expanded, .toggle), (.expanded, .hoverExited):
            return .closed
        case (.expanded(let page), .dragEntered):
            _ = page
            return .acceptingDrop
        case (.expanded, .showPage(let page)):
            return .expanded(page: page)
        case (.acceptingDrop, .showPage(let page)):
            return .expanded(page: page)
        default:
            return self
        }
    }
}
