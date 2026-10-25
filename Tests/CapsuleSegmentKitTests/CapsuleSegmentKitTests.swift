import SwiftUI
import Testing

@testable import CapsuleSegmentKit

@MainActor
@Suite("CapsuleSegmentControl")
struct CapsuleSegmentKitTests {
    private func makeBinding(_ value: Int = 0) -> Binding<Int> {
        .constant(value)
    }

    // MARK: - Initialization

    @Test("Defaults to two items")
    func defaultItems() {
        let control = CapsuleSegmentControl(selectedIndex: makeBinding())
        #expect(control.items == ["Option 1", "Option 2"])
    }

    @Test("Keeps custom items")
    func customItems() {
        let items = ["Option 1", "Option 2", "Option 3", "Option 4"]
        let control = CapsuleSegmentControl(selectedIndex: makeBinding(), items: items)
        #expect(control.items == items)
    }

    @Test("Uses a white selected segment by default")
    func defaultColors() {
        let control = CapsuleSegmentControl(selectedIndex: makeBinding())
        #expect(control.selectedSegmentColor == .white)
    }

    @Test("Keeps custom colors")
    func customColors() {
        let control = CapsuleSegmentControl(
            selectedIndex: makeBinding(),
            backgroundColor: .blue,
            selectedSegmentColor: .red
        )
        #expect(control.backgroundColor == .blue)
        #expect(control.selectedSegmentColor == .red)
    }

    @Test("Enables dragging and haptic feedback by default")
    func interactionDefaults() {
        let control = CapsuleSegmentControl(selectedIndex: makeBinding())
        #expect(control.isDragEnabled)
        #expect(control.hapticFeedback)
    }

    // MARK: - Corner Radius

    @Test("Uses fully rounded ends by default")
    func defaultCornerRadius() {
        let control = CapsuleSegmentControl(selectedIndex: makeBinding())
        #expect(control.cornerRadius == nil)
        #expect(control.resolvedCornerRadius(forHeight: 40) == 20)
    }

    @Test("Uses a custom corner radius")
    func customCornerRadius() {
        let control = CapsuleSegmentControl(selectedIndex: makeBinding(), cornerRadius: 15)
        #expect(control.cornerRadius == 15)
        #expect(control.resolvedCornerRadius(forHeight: 40) == 15)
    }

    @Test("Caps the corner radius at half the height")
    func cornerRadiusIsCapped() {
        let control = CapsuleSegmentControl(selectedIndex: makeBinding(), cornerRadius: 100)
        #expect(control.resolvedCornerRadius(forHeight: 40) == 20)
    }

    // MARK: - Selection

    @Test("Clamps an out-of-range selected index")
    func selectedIndexIsClamped() {
        #expect(CapsuleSegmentControl(selectedIndex: makeBinding(5)).clampedIndex == 1)
        #expect(CapsuleSegmentControl(selectedIndex: makeBinding(-1)).clampedIndex == 0)
    }

    // MARK: - Dragging

    @Test("Maps a horizontal position to an item")
    func indexAtX() {
        // Three items, each 100 points wide.
        #expect(CapsuleSegmentControl.index(atX: 10, itemWidth: 100, count: 3) == 0)
        #expect(CapsuleSegmentControl.index(atX: 150, itemWidth: 100, count: 3) == 1)
        #expect(CapsuleSegmentControl.index(atX: 299, itemWidth: 100, count: 3) == 2)
        #expect(CapsuleSegmentControl.index(atX: 500, itemWidth: 100, count: 3) == 2)
        #expect(CapsuleSegmentControl.index(atX: -20, itemWidth: 100, count: 3) == 0)
    }

    @Test("Keeps the segment within the track")
    func thumbIsClamped() {
        #expect(CapsuleSegmentControl.clampedThumbX(-50, itemWidth: 100, count: 3) == 0)
        #expect(CapsuleSegmentControl.clampedThumbX(120, itemWidth: 100, count: 3) == 120)
        #expect(CapsuleSegmentControl.clampedThumbX(999, itemWidth: 100, count: 3) == 200)
    }

    @Test("Snaps to the nearest item on release")
    func snapToNearest() {
        #expect(CapsuleSegmentControl.nearestIndex(forThumbX: 40, itemWidth: 100, count: 3) == 0)
        #expect(CapsuleSegmentControl.nearestIndex(forThumbX: 60, itemWidth: 100, count: 3) == 1)
        #expect(CapsuleSegmentControl.nearestIndex(forThumbX: 190, itemWidth: 100, count: 3) == 2)
    }
}
