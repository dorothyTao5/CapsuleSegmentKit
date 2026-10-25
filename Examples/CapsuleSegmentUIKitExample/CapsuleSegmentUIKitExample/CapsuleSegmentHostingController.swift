import CapsuleSegmentKit
import SwiftUI
import UIKit

// CapsuleSegmentKit is a SwiftUI control. In UIKit, wrap it in a UIHostingController and use it
// like any other view controller.

/// The appearance of a capsule segmented control in UIKit.
struct CapsuleSegmentStyle {
    var backgroundColor: UIColor = .systemGray5
    var selectedSegmentColor: UIColor = .white
    var textColor: UIColor = .label
    var selectedTextColor: UIColor = .label

    /// The corner radius of both ends, or `nil` for fully rounded ends.
    var cornerRadius: CGFloat? = nil

    var isDragEnabled: Bool = true
}

/// The state that UIKit and SwiftUI share.
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

/// The SwiftUI view that the hosting controller displays.
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

/// A view controller that displays a capsule segmented control in UIKit.
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

    /// Called when the selection changes by tap, drag, or code.
    var onSelectionChanged: ((Int) -> Void)?

    /// The index of the selected item.
    var selectedIndex: Int {
        get { model.selectedIndex }
        set { model.selectedIndex = newValue }
    }

    /// The titles of the items.
    var items: [String] {
        get { model.items }
        set { model.items = newValue }
    }

    init(
        items: [String] = ["Option 1", "Option 2"],
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
        fatalError("Use init(items:selectedIndex:style:) instead.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
}
