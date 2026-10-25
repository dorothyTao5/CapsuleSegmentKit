import SwiftUI

/// A segmented control with capsule-shaped ends that switches by tap or drag.
///
/// By default, the control shows two items with fully rounded ends. You can customize the
/// corner radius, the colors, and the number of items.
///
/// ```swift
/// @State private var selectedIndex = 0
///
/// var body: some View {
///     CapsuleSegmentControl(
///         selectedIndex: $selectedIndex,
///         items: ["Day", "Week", "Month"]
///     )
/// }
/// ```
///
/// People can tap any item, or press and drag the selected segment. When they release it,
/// the segment snaps to the nearest item.
public struct CapsuleSegmentControl: View {
    /// The index of the selected item.
    @Binding public var selectedIndex: Int

    /// The titles of the items, in display order.
    public let items: [String]

    /// The color of the track behind the items.
    public let backgroundColor: Color

    /// The color of the segment that marks the selected item.
    public let selectedSegmentColor: Color

    /// The text color of unselected items.
    public let textColor: Color

    /// The text color of the selected item.
    public let selectedTextColor: Color

    /// The corner radius of both ends, or `nil` for fully rounded ends.
    public let cornerRadius: CGFloat?

    /// The spacing between the selected segment and the edge of the track.
    public let segmentInset: CGFloat

    /// The height of the control.
    public let height: CGFloat

    /// The font of the item titles.
    public let font: Font

    /// A Boolean value that indicates whether people can drag the selected segment.
    public let isDragEnabled: Bool

    /// A Boolean value that indicates whether changing the selection plays haptic feedback.
    public let hapticFeedback: Bool

    /// The in-progress drag, which resets with a spring animation when the gesture ends.
    @GestureState(resetTransaction: Transaction(animation: CapsuleSegmentControl.snapAnimation))
    private var drag: DragInfo? = nil

    /// The animation that moves the selected segment to its resting position.
    static let snapAnimation: Animation = .spring(response: 0.3, dampingFraction: 0.75)

    /// The maximum movement, in points, that still counts as a tap.
    static let tapThreshold: CGFloat = 6

    /// The state of an in-progress drag.
    struct DragInfo: Equatable {
        /// A Boolean value that indicates whether the drag started on the selected segment.
        var isOnThumb: Bool

        /// The horizontal distance moved since the drag started.
        var translation: CGFloat
    }

    /// Creates a capsule segmented control.
    ///
    /// - Parameters:
    ///   - selectedIndex: A binding to the index of the selected item.
    ///   - items: The titles of the items. The default is two items.
    ///   - backgroundColor: The color of the track behind the items.
    ///   - selectedSegmentColor: The color of the segment that marks the selected item.
    ///   - textColor: The text color of unselected items.
    ///   - selectedTextColor: The text color of the selected item.
    ///   - cornerRadius: The corner radius of both ends. Pass `nil` for fully rounded ends.
    ///     Values larger than half the height are reduced to half the height.
    ///   - segmentInset: The spacing between the selected segment and the edge of the track.
    ///   - height: The height of the control.
    ///   - font: The font of the item titles.
    ///   - isDragEnabled: A Boolean value that indicates whether people can drag the selected
    ///     segment.
    ///   - hapticFeedback: A Boolean value that indicates whether changing the selection plays
    ///     haptic feedback.
    public init(
        selectedIndex: Binding<Int>,
        items: [String] = ["Option 1", "Option 2"],
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

    // MARK: - Layout Calculations

    /// Returns the corner radius to draw for the given height, capped at half the height.
    func resolvedCornerRadius(forHeight height: CGFloat) -> CGFloat {
        let capsuleRadius = height / 2
        guard let cornerRadius else { return capsuleRadius }
        return min(cornerRadius, capsuleRadius)
    }

    /// The selected index, clamped to the range of valid item indices.
    var clampedIndex: Int {
        guard !items.isEmpty else { return 0 }
        return min(max(selectedIndex, 0), items.count - 1)
    }

    /// Returns the index of the item at the given horizontal position.
    static func index(atX x: CGFloat, itemWidth: CGFloat, count: Int) -> Int {
        guard count > 0, itemWidth > 0 else { return 0 }
        return min(max(Int(x / itemWidth), 0), count - 1)
    }

    /// Returns the given segment position, clamped between the first and last items.
    static func clampedThumbX(_ x: CGFloat, itemWidth: CGFloat, count: Int) -> CGFloat {
        let maxX = CGFloat(max(count - 1, 0)) * itemWidth
        return min(max(x, 0), maxX)
    }

    /// Returns the index of the item nearest to the given segment position.
    static func nearestIndex(forThumbX x: CGFloat, itemWidth: CGFloat, count: Int) -> Int {
        guard count > 0, itemWidth > 0 else { return 0 }
        return min(max(Int((x / itemWidth).rounded()), 0), count - 1)
    }

    // MARK: - View

    public var body: some View {
        GeometryReader { geometry in
            let count = max(items.count, 1)
            let totalHeight = geometry.size.height
            let itemWidth = geometry.size.width / CGFloat(count)

            let outerRadius = resolvedCornerRadius(forHeight: totalHeight)
            let segmentWidth = max(itemWidth - segmentInset * 2, 0)
            let segmentHeight = max(totalHeight - segmentInset * 2, 0)
            // Subtracting the inset keeps the inner and outer corners concentric.
            let innerRadius = max(outerRadius - segmentInset, 0)

            // While dragging, the segment follows the finger; otherwise it rests on the selection.
            let isDraggingThumb = drag?.isOnThumb == true
            let restingX = CGFloat(clampedIndex) * itemWidth
            let thumbX = isDraggingThumb
                ? Self.clampedThumbX(
                    restingX + (drag?.translation ?? 0),
                    itemWidth: itemWidth,
                    count: items.count
                )
                : restingX
            // The highlighted title follows the segment while dragging.
            let highlightedIndex = isDraggingThumb
                ? Self.nearestIndex(forThumbX: thumbX, itemWidth: itemWidth, count: items.count)
                : clampedIndex

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: outerRadius, style: .continuous)
                    .fill(backgroundColor)

                if !items.isEmpty {
                    RoundedRectangle(cornerRadius: innerRadius, style: .continuous)
                        .fill(selectedSegmentColor)
                        .frame(width: segmentWidth, height: segmentHeight)
                        .scaleEffect(isDraggingThumb ? 0.96 : 1)
                        .animation(.easeOut(duration: 0.15), value: isDraggingThumb)
                        .offset(x: thumbX + segmentInset)
                        .animation(Self.snapAnimation, value: clampedIndex)
                }

                HStack(spacing: 0) {
                    ForEach(items.indices, id: \.self) { index in
                        #if os(tvOS)
                        // tvOS has no touch dragging, so each item is a focusable button.
                        Button {
                            withAnimation(Self.snapAnimation) { selectedIndex = index }
                        } label: {
                            label(
                                at: index,
                                highlightedIndex: highlightedIndex,
                                width: itemWidth,
                                height: totalHeight
                            )
                        }
                        .buttonStyle(.plain)
                        #else
                        label(
                            at: index,
                            highlightedIndex: highlightedIndex,
                            width: itemWidth,
                            height: totalHeight
                        )
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

    /// Returns the title view for the item at the given index.
    private func label(
        at index: Int,
        highlightedIndex: Int,
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        Text(items[index])
            .font(font)
            .lineLimit(1)
            .foregroundStyle(highlightedIndex == index ? selectedTextColor : textColor)
            .animation(.easeInOut(duration: 0.15), value: highlightedIndex)
            .frame(width: width, height: height)
            .contentShape(Rectangle())
            .accessibilityAddTraits(index == clampedIndex ? [.isButton, .isSelected] : .isButton)
            .accessibilityAction {
                withAnimation(Self.snapAnimation) { selectedIndex = index }
            }
    }

    #if !os(tvOS)
    /// Returns a gesture that handles both taps and drags.
    ///
    /// A touch that barely moves selects the item under the finger. A drag that starts on the
    /// selected segment moves the segment with the finger and snaps it to the nearest item on
    /// release.
    private func dragGesture(itemWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .updating($drag) { value, state, _ in
                guard !items.isEmpty else { return }
                if state == nil {
                    let startIndex = Self.index(
                        atX: value.startLocation.x,
                        itemWidth: itemWidth,
                        count: items.count
                    )
                    state = DragInfo(
                        isOnThumb: isDragEnabled && startIndex == clampedIndex,
                        translation: 0
                    )
                }
                state?.translation = value.translation.width
            }
            .onEnded { value in
                guard !items.isEmpty else { return }
                let didMove = abs(value.translation.width) > Self.tapThreshold
                    || abs(value.translation.height) > Self.tapThreshold
                let startIndex = Self.index(
                    atX: value.startLocation.x,
                    itemWidth: itemWidth,
                    count: items.count
                )

                var newIndex: Int?
                if !didMove {
                    newIndex = Self.index(atX: value.location.x, itemWidth: itemWidth, count: items.count)
                } else if isDragEnabled && startIndex == clampedIndex {
                    let releasedX = Self.clampedThumbX(
                        CGFloat(clampedIndex) * itemWidth + value.translation.width,
                        itemWidth: itemWidth,
                        count: items.count
                    )
                    newIndex = Self.nearestIndex(
                        forThumbX: releasedX,
                        itemWidth: itemWidth,
                        count: items.count
                    )
                }

                if let newIndex, newIndex != selectedIndex {
                    withAnimation(Self.snapAnimation) { selectedIndex = newIndex }
                }
            }
    }
    #endif
}

// MARK: - Previews

/// A container that gives previews an interactive selection state.
private struct PreviewHost: View {
    @State private var index: Int
    private let makeControl: (Binding<Int>) -> CapsuleSegmentControl

    init(
        _ initialIndex: Int = 0,
        _ makeControl: @escaping (Binding<Int>) -> CapsuleSegmentControl
    ) {
        _index = State(initialValue: initialIndex)
        self.makeControl = makeControl
    }

    var body: some View { makeControl($index) }
}

#Preview("Default") {
    PreviewHost { CapsuleSegmentControl(selectedIndex: $0) }
        .padding()
}

#Preview("Custom Colors") {
    VStack(spacing: 20) {
        PreviewHost {
            CapsuleSegmentControl(
                selectedIndex: $0,
                items: ["Home", "Explore"],
                backgroundColor: .blue.opacity(0.2),
                selectedSegmentColor: .blue,
                selectedTextColor: .white
            )
        }
        PreviewHost(1) {
            CapsuleSegmentControl(
                selectedIndex: $0,
                items: ["Music", "Videos", "Photos"],
                backgroundColor: .purple.opacity(0.2),
                selectedSegmentColor: .purple,
                selectedTextColor: .white
            )
        }
    }
    .padding()
}

#Preview("Corner Radius") {
    VStack(spacing: 20) {
        PreviewHost {
            CapsuleSegmentControl(selectedIndex: $0, items: ["Square", "Option 2"], cornerRadius: 0)
        }
        PreviewHost {
            CapsuleSegmentControl(selectedIndex: $0, items: ["Rounded", "Option 2"], cornerRadius: 8)
        }
        PreviewHost(1) {
            CapsuleSegmentControl(selectedIndex: $0, items: ["Capsule", "Option 2"])
        }
    }
    .padding()
}
