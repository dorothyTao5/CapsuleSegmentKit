# CapsuleSegmentUIKitExample

Shows how to use **CapsuleSegmentKit** in a UIKit app built entirely in code, without storyboards.

## Run the Example

1. Close any Xcode window that has the `CapsuleSegmentKit` package open.
2. Open `CapsuleSegmentUIKitExample.xcodeproj`.
3. Choose the `CapsuleSegmentUIKitExample` scheme and an iPhone simulator, then press ⌘R.

## How It Works

CapsuleSegmentKit is a SwiftUI control, so UIKit uses it through `UIHostingController`. This example
wraps that in `CapsuleSegmentHostingController`, which you can use like any other view controller:

```swift
import UIKit

final class MyViewController: UIViewController {
    private let segment = CapsuleSegmentHostingController(
        items: ["In Progress", "Done"],
        style: CapsuleSegmentStyle(
            backgroundColor: UIColor.systemOrange.withAlphaComponent(0.15),
            selectedSegmentColor: .systemOrange,
            textColor: .systemOrange,
            selectedTextColor: .white,
            cornerRadius: nil  // nil = capsule (default)
        )
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(segment)
        segment.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segment.view)
        NSLayoutConstraint.activate([
            segment.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segment.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segment.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            segment.view.heightAnchor.constraint(equalToConstant: 40),
        ])
        segment.didMove(toParent: self)

        // Called on tap or drag.
        segment.onSelectionChanged = { index in
            print("Selected: \(index)")
        }

        // Switch programmatically.
        segment.selectedIndex = 1
    }
}
```

## Files

| File | Description |
|------|-------------|
| `CapsuleSegmentHostingController.swift` | The UIKit–SwiftUI bridge. Copy it into your project. |
| `ViewController.swift` | Three examples: custom colors that switch content, the default style, and a custom corner radius without dragging. |
| `AppDelegate.swift` / `SceneDelegate.swift` | The app entry point without a storyboard. |

Requires iOS 17 or later.
