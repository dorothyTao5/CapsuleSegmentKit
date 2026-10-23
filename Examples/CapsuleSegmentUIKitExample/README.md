# CapsuleSegmentUIKitExample

示範在 **UIKit 專案（純 Swift 程式碼、不用 Storyboard）** 中使用 **CapsuleSegmentKit**。

## 執行

1. 先關閉已開啟 `CapsuleSegmentKit` 套件的 Xcode 視窗。
2. 打開 `CapsuleSegmentUIKitExample.xcodeproj`。
3. scheme 選 `CapsuleSegmentUIKitExample`，執行目標選 iPhone 模擬器，按 ⌘R。

## 原理

CapsuleSegmentKit 是 SwiftUI 元件，UIKit 透過 `UIHostingController` 使用它。
本範例把這層包成 `CapsuleSegmentHostingController`，用起來就像一般的 UIViewController：

```swift
import UIKit

final class MyViewController: UIViewController {

    private let segment = CapsuleSegmentHostingController(
        items: ["進行中", "已完成"],
        style: CapsuleSegmentStyle(
            backgroundColor: UIColor.systemOrange.withAlphaComponent(0.15),
            selectedSegmentColor: .systemOrange,
            textColor: .systemOrange,
            selectedTextColor: .white,
            cornerRadius: nil          // nil = 半圓（預設）
        )
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        // 加入畫面
        addChild(segment)
        segment.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segment.view)
        NSLayoutConstraint.activate([
            segment.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segment.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segment.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            segment.view.heightAnchor.constraint(equalToConstant: 40)
        ])
        segment.didMove(toParent: self)

        // 監聽切換（點擊或拖曳）
        segment.onSelectionChanged = { index in
            print("選中：\(index)")
        }

        // 用程式切換
        segment.selectedIndex = 1
    }
}
```

## 檔案

| 檔案 | 說明 |
|------|------|
| `CapsuleSegmentHostingController.swift` | UIKit ↔ SwiftUI 橋接，可直接複製到你的專案 |
| `ViewController.swift` | 3 個使用範例：自訂顏色切換內容、預設樣式、自訂弧度並關閉拖曳 |
| `AppDelegate.swift` / `SceneDelegate.swift` | 不使用 Storyboard 的 App 進入點 |

最低需求：iOS 17。
