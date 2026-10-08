import XCTest
@testable import WindowEngine

final class IslandStateTests: XCTestCase {
    // MARK: Hover expand / collapse

    func testHoverExpandsFromClosed() {
        XCTAssertEqual(IslandState.closed.applying(.hoverEntered), .expanded(page: .home))
    }

    func testHoverExitsCollapseFromExpanded() {
        XCTAssertEqual(IslandState.expanded(page: .home).applying(.hoverExited), .closed)
    }

    func testToggleExpandsAndCollapses() {
        XCTAssertEqual(IslandState.closed.applying(.toggle), .expanded(page: .home))
        XCTAssertEqual(IslandState.expanded(page: .home).applying(.toggle), .closed)
    }

    // MARK: Drag

    func testDragOverClosedOpensDropTarget() {
        XCTAssertEqual(IslandState.closed.applying(.dragEntered), .acceptingDrop)
    }

    func testDragEndClosesAcceptingState() {
        XCTAssertEqual(IslandState.acceptingDrop.applying(.dragExited), .closed)
    }

    func testDragOverExpandedKeepsDropTarget() {
        XCTAssertEqual(
            IslandState.expanded(page: .tray).applying(.dragEntered),
            .acceptingDrop
        )
    }

    // MARK: Pages

    func testPageSwitchWhileExpanded() {
        let state = IslandState.expanded(page: .home).applying(.showPage(.tray))
        XCTAssertEqual(state, .expanded(page: .tray))
    }

    // MARK: Dismiss wins from anywhere

    func testDismissAlwaysCloses() {
        for state in [IslandState.closed, .expanded(page: .widgets), .acceptingDrop] {
            XCTAssertEqual(state.applying(.dismiss), .closed, "from \(state)")
        }
    }

    // MARK: No-op events don't churn state (controller guards on equality)

    func testIrrelevantEventsAreNoOps() {
        XCTAssertEqual(IslandState.closed.applying(.hoverExited), .closed)
        XCTAssertEqual(IslandState.closed.applying(.dragExited), .closed)
        XCTAssertEqual(IslandState.acceptingDrop.applying(.hoverEntered), .acceptingDrop)
    }

    // MARK: Interruptibility contract (rapid toggles settle on latest event)

    func testRapidTogglesSettleClosed() {
        var state = IslandState.closed
        for _ in 0..<10 { state = state.applying(.toggle) }
        XCTAssertEqual(state, .closed, "even count of toggles returns to closed")
    }
}
