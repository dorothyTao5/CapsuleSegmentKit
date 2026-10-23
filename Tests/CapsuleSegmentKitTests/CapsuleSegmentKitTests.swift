import Testing
import SwiftUI
@testable import CapsuleSegmentKit

@MainActor
@Suite("CapsuleSegmentControl 測試")
struct CapsuleSegmentKitTests {

    private func makeBinding(_ value: Int = 0) -> Binding<Int> {
        .constant(value)
    }

    @Test("預設初始化應該有 2 個項目")
    func defaultInitialization() {
        let control = CapsuleSegmentControl(selectedIndex: makeBinding())
        #expect(control.items.count == 2)
    }

    @Test("自訂項目數量")
    func customItemCount() {
        let items = ["選項 1", "選項 2", "選項 3", "選項 4"]
        let control = CapsuleSegmentControl(selectedIndex: makeBinding(), items: items)
        #expect(control.items == items)
    }

    @Test("預設顏色設定")
    func defaultColors() {
        let control = CapsuleSegmentControl(selectedIndex: makeBinding())
        #expect(control.selectedSegmentColor == .white)
    }

    @Test("自訂顏色")
    func customColors() {
        let control = CapsuleSegmentControl(
            selectedIndex: makeBinding(),
            backgroundColor: .blue,
            selectedSegmentColor: .red
        )
        #expect(control.backgroundColor == .blue)
        #expect(control.selectedSegmentColor == .red)
    }

    @Test("預設為半圓形")
    func defaultCornerRadius() {
        let control = CapsuleSegmentControl(selectedIndex: makeBinding())
        #expect(control.cornerRadius == nil)
        #expect(control.resolvedCornerRadius(forHeight: 40) == 20)
    }

    @Test("自訂圓角半徑")
    func customCornerRadius() {
        let control = CapsuleSegmentControl(selectedIndex: makeBinding(), cornerRadius: 15)
        #expect(control.cornerRadius == 15)
        #expect(control.resolvedCornerRadius(forHeight: 40) == 15)
    }

    @Test("圓角不會超過半圓")
    func cornerRadiusIsClamped() {
        let control = CapsuleSegmentControl(selectedIndex: makeBinding(), cornerRadius: 100)
        #expect(control.resolvedCornerRadius(forHeight: 40) == 20)
    }

    @Test("超出範圍的索引會被限制")
    func indexIsClamped() {
        #expect(CapsuleSegmentControl(selectedIndex: makeBinding(5)).clampedIndex == 1)
        #expect(CapsuleSegmentControl(selectedIndex: makeBinding(-1)).clampedIndex == 0)
    }

    // MARK: - 拖曳計算

    @Test("x 座標對應到正確項目")
    func indexAtX() {
        // 3 個項目，每個寬 100
        #expect(CapsuleSegmentControl.index(atX: 10, itemWidth: 100, count: 3) == 0)
        #expect(CapsuleSegmentControl.index(atX: 150, itemWidth: 100, count: 3) == 1)
        #expect(CapsuleSegmentControl.index(atX: 299, itemWidth: 100, count: 3) == 2)
        #expect(CapsuleSegmentControl.index(atX: 500, itemWidth: 100, count: 3) == 2)
        #expect(CapsuleSegmentControl.index(atX: -20, itemWidth: 100, count: 3) == 0)
    }

    @Test("滑塊不會被拖出範圍")
    func thumbIsClamped() {
        #expect(CapsuleSegmentControl.clampedThumbX(-50, itemWidth: 100, count: 3) == 0)
        #expect(CapsuleSegmentControl.clampedThumbX(120, itemWidth: 100, count: 3) == 120)
        #expect(CapsuleSegmentControl.clampedThumbX(999, itemWidth: 100, count: 3) == 200)
    }

    @Test("放開後吸附到最近的項目")
    func snapToNearest() {
        #expect(CapsuleSegmentControl.nearestIndex(forThumbX: 40, itemWidth: 100, count: 3) == 0)
        #expect(CapsuleSegmentControl.nearestIndex(forThumbX: 60, itemWidth: 100, count: 3) == 1)
        #expect(CapsuleSegmentControl.nearestIndex(forThumbX: 190, itemWidth: 100, count: 3) == 2)
    }

    @Test("預設允許拖曳與觸覺回饋")
    func dragDefaults() {
        let control = CapsuleSegmentControl(selectedIndex: makeBinding())
        #expect(control.isDragEnabled)
        #expect(control.hapticFeedback)
    }
}
