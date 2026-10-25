# Getting Started with CapsuleSegmentKit

Add a capsule segmented control to your app and customize how it looks and behaves.

## Overview

This article shows how to install the package, add a control to a SwiftUI view, show
SF Symbols, and use the control in UIKit.

### Add the package to your project

In Xcode, choose File > Add Package Dependencies, then enter the package URL:

```
https://github.com/dorothyTao5/CapsuleSegmentKit
```

To add the package to another Swift package instead, add it to the dependencies in your
`Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/dorothyTao5/CapsuleSegmentKit", from: "1.0.0")
]
```

### Add a control to a view

Bind the control to an integer that stores the selected index. Without any other arguments,
the control shows two items with fully rounded ends.

```swift
@State private var selectedIndex = 0

var body: some View {
    CapsuleSegmentControl(selectedIndex: $selectedIndex)
}
```

### Customize the appearance

Pass your own titles, colors, and corner radius. A `nil` corner radius gives fully rounded
ends, and values larger than half the height are reduced to half the height.

```swift
CapsuleSegmentControl(
    selectedIndex: $selectedIndex,
    items: ["For You", "Following", "Trending"],
    backgroundColor: .orange.opacity(0.15),
    selectedSegmentColor: .orange,
    textColor: .orange,
    selectedTextColor: .white,
    cornerRadius: 8
)
```

### Show SF Symbols

Use ``CapsuleSegmentItem`` to show an SF Symbol with each title. To show only the images, apply
`labelStyle(_:)` with the `iconOnly` style. VoiceOver still reads each title, so give every
item a meaningful title.

```swift
CapsuleSegmentControl(
    selectedIndex: $selectedIndex,
    items: [
        CapsuleSegmentItem("List", systemImage: "list.bullet"),
        CapsuleSegmentItem("Grid", systemImage: "square.grid.2x2"),
    ]
)
.labelStyle(.iconOnly)
```

### Control the interaction

By default, people can drag the selected segment, and changing the selection plays a haptic on
iPhone. Turn off either behavior with ``CapsuleSegmentControl/isDragEnabled`` and
``CapsuleSegmentControl/hapticFeedback``.

```swift
CapsuleSegmentControl(
    selectedIndex: $selectedIndex,
    items: ["Day", "Week", "Month"],
    isDragEnabled: false,
    hapticFeedback: false
)
```

### Use the control in UIKit

Wrap the control in a `UIHostingController` and add it to your view controller as a child.
The UIKit example project in the repository includes a ready-to-use bridge,
`CapsuleSegmentHostingController`, that you can copy into your app.
