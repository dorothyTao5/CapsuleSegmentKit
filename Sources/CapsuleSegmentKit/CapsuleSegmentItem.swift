/// An item in a capsule segmented control, with a title and an optional SF Symbol.
///
/// Create items with a title and a symbol name:
///
/// ```swift
/// CapsuleSegmentControl(
///     selectedIndex: $selectedIndex,
///     items: [
///         CapsuleSegmentItem("List", systemImage: "list.bullet"),
///         CapsuleSegmentItem("Grid", systemImage: "square.grid.2x2"),
///     ]
/// )
/// ```
///
/// To show only the images, apply `.labelStyle(.iconOnly)` to the control. VoiceOver still reads
/// each item's title, so give every item a meaningful title.
public struct CapsuleSegmentItem: Hashable, Sendable {
    /// The title of the item.
    public var title: String

    /// The name of the SF Symbol to show with the title, or `nil` to show only the title.
    public var systemImage: String?

    /// Creates an item with a title and an optional SF Symbol.
    ///
    /// - Parameters:
    ///   - title: The title of the item.
    ///   - systemImage: The name of the SF Symbol to show with the title.
    public init(_ title: String, systemImage: String? = nil) {
        self.title = title
        self.systemImage = systemImage
    }
}

extension CapsuleSegmentItem: ExpressibleByStringLiteral {
    /// Creates a title-only item from a string literal.
    public init(stringLiteral value: String) {
        self.init(value)
    }
}
