import CapsuleSegmentKit
import SwiftUI

#if os(macOS)
import AppKit
#endif

@main
struct CapsuleSegmentDemoApp: App {
    init() {
        #if os(macOS)
        // Bring the window to the front when the app runs from a Swift package.
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
