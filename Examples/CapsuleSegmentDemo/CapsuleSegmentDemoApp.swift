import SwiftUI
import CapsuleSegmentKit
#if os(macOS)
import AppKit
#endif

@main
struct CapsuleSegmentDemoApp: App {
    init() {
        #if os(macOS)
        // 從 Swift Package 執行時，讓視窗正常顯示在最前面
        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.activate(ignoringOtherApps: true)
        #endif
    }

    var body: some Scene {
        WindowGroup("CapsuleSegmentKit Demo") {
            DemoView()
                .frame(minWidth: 520, minHeight: 640)
        }
    }
}
