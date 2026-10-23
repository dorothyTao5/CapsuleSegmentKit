import SwiftUI

/// 一個可自訂的膠囊分段控制元件。
///
/// - 兩側弧度：`cornerRadius` 為 `nil` 時是半圓（膠囊形），也可以指定固定半徑。
/// - 顏色：可自訂背景顏色、選中 segment 顏色與文字顏色。
/// - 數量：預設為 2 個項目。
/// - 切換：點擊任一項目，或按住選中的 segment 左右拖曳，放開後自動吸附。
public struct CapsuleSegmentControl: View {
    /// 選中的索引
    @Binding public var selectedIndex: Int

    /// 分段項目
    public let items: [String]

    /// 背景顏色
    public let backgroundColor: Color

    /// 選中的 segment 顏色
    public let selectedSegmentColor: Color

    /// 文字顏色（未選中）
    public let textColor: Color

    /// 文字顏色（選中）
    public let selectedTextColor: Color

    /// 兩側的圓角半徑（`nil` 表示半圓形）
    public let cornerRadius: CGFloat?

    /// 選中 segment 與背景邊緣的間距
    public let segmentInset: CGFloat

    /// 元件高度
    public let height: CGFloat

    /// 文字字型
    public let font: Font

    /// 是否允許拖曳切換
    public let isDragEnabled: Bool

    /// 切換時是否有觸覺回饋（iPhone）
    public let hapticFeedback: Bool

    /// 拖曳中的狀態；手勢結束或被取消時會自動以彈簧動畫歸位
    @GestureState(resetTransaction: Transaction(animation: CapsuleSegmentControl.snapAnimation))
    private var drag: DragInfo? = nil

    static let snapAnimation: Animation = .spring(response: 0.3, dampingFraction: 0.75)

    /// 移動距離小於此值視為點擊
    static let tapThreshold: CGFloat = 6

    struct DragInfo: Equatable {
        /// 是否從選中的 segment 開始拖曳
        var isOnThumb: Bool
        /// 水平位移
        var translation: CGFloat
    }

    /// 初始化方法
    /// - Parameters:
    ///   - selectedIndex: 綁定的選中索引
    ///   - items: 分段項目的標題陣列（預設為 2 個項目）
    ///   - backgroundColor: 背景顏色（預設為淺灰色）
    ///   - selectedSegmentColor: 選中的 segment 顏色（預設為白色）
    ///   - textColor: 未選中時的文字顏色（預設為 `.primary`）
    ///   - selectedTextColor: 選中時的文字顏色（預設為 `.primary`）
    ///   - cornerRadius: 兩側圓角半徑，`nil` 表示半圓形（預設為 `nil`）
    ///   - segmentInset: 選中 segment 的內縮距離（預設為 2）
    ///   - height: 元件高度（預設為 40）
    ///   - font: 文字字型（預設為 14pt medium）
    ///   - isDragEnabled: 是否允許拖曳切換（預設為 `true`）
    ///   - hapticFeedback: 切換時是否有觸覺回饋（預設為 `true`）
    public init(
        selectedIndex: Binding<Int>,
        items: [String] = ["選項 1", "選項 2"],
        backgroundColor: Color = Color.gray.opacity(0.2),
        selectedSegmentColor: Color = .white,
        textColor: Color = .primary,
        selectedTextColor: Color = .primary,
        cornerRadius: CGFloat? = nil,
        segmentInset: CGFloat = 2,
        height: CGFloat = 40,
        font: Font = .system(size: 14, weight: .medium),
        isDragEnabled: Bool = true,
        hapticFeedback: Bool = true
    ) {
        self._selectedIndex = selectedIndex
        self.items = items
        self.backgroundColor = backgroundColor
        self.selectedSegmentColor = selectedSegmentColor
        self.textColor = textColor
        self.selectedTextColor = selectedTextColor
        self.cornerRadius = cornerRadius.map { max(0, $0) }
        self.segmentInset = max(0, segmentInset)
        self.height = height
        self.font = font
        self.isDragEnabled = isDragEnabled
        self.hapticFeedback = hapticFeedback
    }

    // MARK: - 計算

    /// 依高度算出實際使用的圓角（最大為半圓）
    func resolvedCornerRadius(forHeight height: CGFloat) -> CGFloat {
        let capsule = height / 2
        guard let cornerRadius else { return capsule }
        return min(cornerRadius, capsule)
    }

    /// 限制在合法範圍內的選中索引
    var clampedIndex: Int {
        guard !items.isEmpty else { return 0 }
        return min(max(selectedIndex, 0), items.count - 1)
    }

    /// 某個 x 座標落在第幾個項目
    static func index(atX x: CGFloat, itemWidth: CGFloat, count: Int) -> Int {
        guard count > 0, itemWidth > 0 else { return 0 }
        return min(max(Int(x / itemWidth), 0), count - 1)
    }

    /// 把滑塊位置限制在第一個與最後一個項目之間
    static func clampedThumbX(_ x: CGFloat, itemWidth: CGFloat, count: Int) -> CGFloat {
        let maxX = CGFloat(max(count - 1, 0)) * itemWidth
        return min(max(x, 0), maxX)
    }

    /// 滑塊位置最接近的項目
    static func nearestIndex(forThumbX x: CGFloat, itemWidth: CGFloat, count: Int) -> Int {
        guard count > 0, itemWidth > 0 else { return 0 }
        return min(max(Int((x / itemWidth).rounded()), 0), count - 1)
    }

    // MARK: - Body

    public var body: some View {
        GeometryReader { geometry in
            let count = max(items.count, 1)
            let totalWidth = geometry.size.width
            let totalHeight = geometry.size.height
            let itemWidth = totalWidth / CGFloat(count)

            let outerRadius = resolvedCornerRadius(forHeight: totalHeight)
            let segmentWidth = max(itemWidth - segmentInset * 2, 0)
            let segmentHeight = max(totalHeight - segmentInset * 2, 0)
            // 內層圓角 = 外層圓角 - 內縮，讓兩層弧度保持同心
            let innerRadius = max(outerRadius - segmentInset, 0)

            // 滑塊目前位置：拖曳中跟著手指，否則停在選中項目
            let isDraggingThumb = drag?.isOnThumb == true
            let baseX = CGFloat(clampedIndex) * itemWidth
            let thumbX = isDraggingThumb
                ? Self.clampedThumbX(baseX + (drag?.translation ?? 0), itemWidth: itemWidth, count: items.count)
                : baseX
            // 文字高亮跟著滑塊走
            let highlightedIndex = isDraggingThumb
                ? Self.nearestIndex(forThumbX: thumbX, itemWidth: itemWidth, count: items.count)
                : clampedIndex

            ZStack(alignment: .leading) {
                // 背景
                RoundedRectangle(cornerRadius: outerRadius, style: .continuous)
                    .fill(backgroundColor)

                // 選中的滑塊
                if !items.isEmpty {
                    RoundedRectangle(cornerRadius: innerRadius, style: .continuous)
                        .fill(selectedSegmentColor)
                        .frame(width: segmentWidth, height: segmentHeight)
                        .scaleEffect(isDraggingThumb ? 0.96 : 1)
                        .animation(.easeOut(duration: 0.15), value: isDraggingThumb)
                        .offset(x: thumbX + segmentInset)
                        .animation(Self.snapAnimation, value: clampedIndex)
                }

                // 分段項目
                HStack(spacing: 0) {
                    ForEach(items.indices, id: \.self) { index in
                        #if os(tvOS)
                        // tvOS 沒有觸控拖曳，使用按鈕配合遙控器焦點
                        Button {
                            withAnimation(Self.snapAnimation) { selectedIndex = index }
                        } label: {
                            label(at: index, highlighted: highlightedIndex, width: itemWidth, height: totalHeight)
                        }
                        .buttonStyle(.plain)
                        #else
                        label(at: index, highlighted: highlightedIndex, width: itemWidth, height: totalHeight)
                        #endif
                    }
                }
            }
            .contentShape(Rectangle())
            #if !os(tvOS)
            .gesture(dragGesture(itemWidth: itemWidth))
            #endif
            .sensoryFeedback(.selection, trigger: highlightedIndex) { _, _ in hapticFeedback }
        }
        .frame(height: height)
    }

    /// 單一項目的文字
    private func label(at index: Int, highlighted: Int, width: CGFloat, height: CGFloat) -> some View {
        Text(items[index])
            .font(font)
            .lineLimit(1)
            .foregroundStyle(highlighted == index ? selectedTextColor : textColor)
            .animation(.easeInOut(duration: 0.15), value: highlighted)
            .frame(width: width, height: height)
            .contentShape(Rectangle())
            .accessibilityAddTraits(index == clampedIndex ? [.isButton, .isSelected] : .isButton)
            .accessibilityAction {
                withAnimation(Self.snapAnimation) { selectedIndex = index }
            }
    }

    #if !os(tvOS)
    /// 點擊與拖曳共用一個手勢：
    /// - 移動很小 → 視為點擊，切到手指所在項目
    /// - 從選中的 segment 開始拖 → 滑塊跟著手指，放開後吸附到最近項目
    private func dragGesture(itemWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .updating($drag) { value, state, _ in
                guard !items.isEmpty else { return }
                if state == nil {
                    let start = Self.index(atX: value.startLocation.x, itemWidth: itemWidth, count: items.count)
                    state = DragInfo(isOnThumb: isDragEnabled && start == clampedIndex, translation: 0)
                }
                state?.translation = value.translation.width
            }
            .onEnded { value in
                guard !items.isEmpty else { return }
                let moved = abs(value.translation.width) > Self.tapThreshold
                    || abs(value.translation.height) > Self.tapThreshold
                let startIndex = Self.index(atX: value.startLocation.x, itemWidth: itemWidth, count: items.count)

                var newIndex: Int?
                if !moved {
                    // 點擊
                    newIndex = Self.index(atX: value.location.x, itemWidth: itemWidth, count: items.count)
                } else if isDragEnabled && startIndex == clampedIndex {
                    // 拖曳結束，吸附到最近項目
                    let x = Self.clampedThumbX(
                        CGFloat(clampedIndex) * itemWidth + value.translation.width,
                        itemWidth: itemWidth,
                        count: items.count
                    )
                    newIndex = Self.nearestIndex(forThumbX: x, itemWidth: itemWidth, count: items.count)
                }

                if let newIndex, newIndex != selectedIndex {
                    withAnimation(Self.snapAnimation) { selectedIndex = newIndex }
                }
            }
    }
    #endif
}

// MARK: - Previews

/// 預覽用：提供可互動的 @State
private struct PreviewHost: View {
    @State private var index: Int
    private let make: (Binding<Int>) -> CapsuleSegmentControl

    init(_ initial: Int = 0, _ make: @escaping (Binding<Int>) -> CapsuleSegmentControl) {
        _index = State(initialValue: initial)
        self.make = make
    }

    var body: some View { make($index) }
}

#Preview("預設樣式") {
    PreviewHost { CapsuleSegmentControl(selectedIndex: $0) }
        .padding()
}

#Preview("自訂顏色") {
    VStack(spacing: 20) {
        PreviewHost {
            CapsuleSegmentControl(
                selectedIndex: $0,
                items: ["首頁", "探索"],
                backgroundColor: .blue.opacity(0.2),
                selectedSegmentColor: .blue,
                selectedTextColor: .white
            )
        }
        PreviewHost(1) {
            CapsuleSegmentControl(
                selectedIndex: $0,
                items: ["音樂", "影片", "照片"],
                backgroundColor: .purple.opacity(0.2),
                selectedSegmentColor: .purple,
                selectedTextColor: .white
            )
        }
    }
    .padding()
}

#Preview("自訂兩側弧度") {
    VStack(spacing: 20) {
        PreviewHost { CapsuleSegmentControl(selectedIndex: $0, items: ["直角", "選項 2"], cornerRadius: 0) }
        PreviewHost { CapsuleSegmentControl(selectedIndex: $0, items: ["小圓角", "選項 2"], cornerRadius: 8) }
        PreviewHost(1) { CapsuleSegmentControl(selectedIndex: $0, items: ["預設半圓", "選項 2"]) }
    }
    .padding()
}
