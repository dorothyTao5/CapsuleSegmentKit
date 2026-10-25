# CapsuleSegmentKit

English | [繁體中文](README.zh-TW.md)

A customizable SwiftUI capsule segmented control with adjustable corner radius, colors, and item count, supporting both tap and drag to switch.

<p align="center">
  <img src="docs/demo.gif" alt="CapsuleSegmentKit demo: switching by tap and drag" width="295">
</p>

## Features

- **Customizable corner radius**: a full capsule (half-circle ends) by default, or any radius you choose; values larger than half the height are capped to a capsule
- **Customizable colors**: background, selected segment, text, and selected text
- **Flexible item count**: 2 items by default, any number supported
- **Tap and drag to switch**: press and drag the selected segment, and it snaps to the nearest item with a spring animation on release
- **Haptic feedback**: a subtle selection haptic on iPhone, can be turned off
- **SwiftUI and UIKit**: use it in UIKit through `UIHostingController`, with a complete example
- **No third-party dependencies**

## Installation

### Swift Package Manager

In Xcode, choose **File → Add Package Dependencies…** and enter:

```
https://github.com/dorothyTao5/CapsuleSegmentKit
```

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/dorothyTao5/CapsuleSegmentKit", from: "1.0.0")
]
```

## Usage

### SwiftUI

```swift
import SwiftUI
import CapsuleSegmentKit

struct ContentView: View {
    @State private var selectedIndex = 0

    var body: some View {
        // Default: 2 items with capsule-shaped ends
        CapsuleSegmentControl(selectedIndex: $selectedIndex)
            .padding()
    }
}
```

Custom items, colors, and corner radius:

```swift
CapsuleSegmentControl(
    selectedIndex: $selectedIndex,
    items: ["For You", "Following", "Trending"],
    backgroundColor: .orange.opacity(0.15),
    selectedSegmentColor: .orange,
    textColor: .orange,
    selectedTextColor: .white,
    cornerRadius: 8          // nil = capsule (default)
)
```

Tap only, with dragging disabled:

```swift
CapsuleSegmentControl(
    selectedIndex: $selectedIndex,
    items: ["Day", "Week", "Month"],
    isDragEnabled: false
)
```

### UIKit

Wrap the control in a `UIHostingController` and add it like any other view controller. The complete bridge is in [`CapsuleSegmentHostingController.swift`](Examples/CapsuleSegmentUIKitExample/CapsuleSegmentUIKitExample/CapsuleSegmentHostingController.swift), which you can copy into your project.

```swift
let segment = CapsuleSegmentHostingController(items: ["In Progress", "Done"])
addChild(segment)
view.addSubview(segment.view)          // then add Auto Layout constraints, height 40
segment.didMove(toParent: self)

segment.onSelectionChanged = { index in print(index) }   // called on tap or drag
segment.selectedIndex = 1                                 // switch programmatically
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `selectedIndex` | `Binding<Int>` | Required | The selected index |
| `items` | `[String]` | `["Option 1", "Option 2"]` | Item titles |
| `backgroundColor` | `Color` | `Color.gray.opacity(0.2)` | Background color |
| `selectedSegmentColor` | `Color` | `.white` | Color of the selected segment |
| `textColor` | `Color` | `.primary` | Text color of unselected items |
| `selectedTextColor` | `Color` | `.primary` | Text color of the selected item |
| `cornerRadius` | `CGFloat?` | `nil` | Corner radius of both ends; `nil` for a capsule |
| `segmentInset` | `CGFloat` | `2` | Spacing between the selected segment and the background edge |
| `height` | `CGFloat` | `40` | Height of the control |
| `font` | `Font` | `.system(size: 14, weight: .medium)` | Text font |
| `isDragEnabled` | `Bool` | `true` | Whether dragging to switch is allowed |
| `hapticFeedback` | `Bool` | `true` | Whether switching plays haptic feedback |

## Example Projects

| Example | How to run | What it shows |
|---------|------------|---------------|
| [`CapsuleSegmentUIKitExample`](Examples/CapsuleSegmentUIKitExample) | Open the `.xcodeproj`, choose an iPhone simulator, press ⌘R | Three use cases in UIKit |
| [`CapsuleSegmentDemo`](Examples/CapsuleSegmentDemo) | Open the package, choose the `CapsuleSegmentDemo` scheme and My Mac, press ⌘R | A playground for adjusting every parameter live |

Unit tests: open the package, choose the `CapsuleSegmentKit` scheme, and press ⌘U.

## Requirements

- iOS 17.0+ / macOS 14.0+ / tvOS 17.0+ / watchOS 10.0+ / visionOS 1.0+
- Xcode 26+ (Swift 6.2)

## License

MIT License. See [LICENSE](LICENSE) for details.
