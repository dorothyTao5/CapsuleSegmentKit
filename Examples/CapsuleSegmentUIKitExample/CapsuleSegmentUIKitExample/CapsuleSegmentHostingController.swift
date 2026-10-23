import UIKit
import SwiftUI
// 1️⃣ 匯入套件
import CapsuleSegmentKit

// CapsuleSegmentKit 是用 SwiftUI 寫的元件。
// 在 UIKit 專案中，用 UIHostingController 包起來，就能像一般 UIViewController 一樣使用。

/// UIKit 用的外觀設定
struct CapsuleSegmentStyle {
    var backgroundColor: UIColor = .systemGray5
    var selectedSegmentColor: UIColor = .white
    var textColor: UIColor = .label
    var selectedTextColor: UIColor = .label
    /// nil = 兩側半圓（預設）
    var cornerRadius: CGFloat? = nil
    var isDragEnabled: Bool = true
}

/// 在 UIKit 與 SwiftUI 之間共用的狀態
@Observable
final class CapsuleSegmentModel {
    var selectedIndex: Int
    var items: [String]
    var style: CapsuleSegmentStyle

    @ObservationIgnored
    var onChange: ((Int) -> Void)?

    init(items: [String], selectedIndex: Int, style: CapsuleSegmentStyle) {
        self.items = items
        self.selectedIndex = selectedIndex
        self.style = style
    }
}

/// 被 UIHostingController 包住的 SwiftUI 畫面
struct CapsuleSegmentRootView: View {
    @Bindable var model: CapsuleSegmentModel

    var body: some View {
        CapsuleSegmentControl(
            selectedIndex: $model.selectedIndex,
            items: model.items,
            backgroundColor: Color(uiColor: model.style.backgroundColor),
            selectedSegmentColor: Color(uiColor: model.style.selectedSegmentColor),
            textColor: Color(uiColor: model.style.textColor),
            selectedTextColor: Color(uiColor: model.style.selectedTextColor),
            cornerRadius: model.style.cornerRadius,
            isDragEnabled: model.style.isDragEnabled
        )
        .onChange(of: model.selectedIndex) { _, newValue in
            model.onChange?(newValue)
        }
    }
}

/// 給 UIKit 使用的 CapsuleSegment 控制器
///
/// ```swift
/// let segment = CapsuleSegmentHostingController(items: ["A", "B"])
/// segment.onSelectionChanged = { index in print(index) }
/// addChild(segment)
/// view.addSubview(segment.view)
/// segment.didMove(toParent: self)
/// ```
final class CapsuleSegmentHostingController: UIHostingController<CapsuleSegmentRootView> {

    private let model: CapsuleSegmentModel

    /// 選中項目改變時呼叫（點擊、拖曳或程式設定）
    var onSelectionChanged: ((Int) -> Void)?

    /// 目前選中的索引，也可以用程式設定
    var selectedIndex: Int {
        get { model.selectedIndex }
        set { model.selectedIndex = newValue }
    }

    /// 項目標題，可以隨時更換
    var items: [String] {
        get { model.items }
        set { model.items = newValue }
    }

    init(
        items: [String] = ["選項 1", "選項 2"],
        selectedIndex: Int = 0,
        style: CapsuleSegmentStyle = CapsuleSegmentStyle()
    ) {
        let model = CapsuleSegmentModel(items: items, selectedIndex: selectedIndex, style: style)
        self.model = model
        super.init(rootView: CapsuleSegmentRootView(model: model))
        model.onChange = { [weak self] index in
            self?.onSelectionChanged?(index)
        }
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("請使用 init(items:selectedIndex:style:)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
}
