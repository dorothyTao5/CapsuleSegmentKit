# ``CapsuleSegmentKit``

A customizable segmented control with capsule-shaped ends that switches by tap or drag.

## Overview

CapsuleSegmentKit provides ``CapsuleSegmentControl``, a SwiftUI segmented control you can style
to match your app. Adjust the corner radius of both ends, the colors, and the number of items,
and show an SF Symbol with each title.

![A UIKit screen with three capsule segmented controls in orange, gray, and indigo.](capsule-segment-demo)

People can tap any item, or press and drag the selected segment. When they release it, the
segment snaps to the nearest item with a spring animation and a subtle haptic.

```swift
import CapsuleSegmentKit
import SwiftUI

struct ContentView: View {
    @State private var selectedIndex = 0

    var body: some View {
        CapsuleSegmentControl(
            selectedIndex: $selectedIndex,
            items: ["Day", "Week", "Month"]
        )
        .padding()
    }
}
```

## Topics

### Essentials

- <doc:GettingStarted>
- ``CapsuleSegmentControl``

### Items

- ``CapsuleSegmentItem``
