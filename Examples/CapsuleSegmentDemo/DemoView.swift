import CapsuleSegmentKit
import SwiftUI

/// A playground for adjusting every parameter of the control live.
struct DemoView: View {
    @State private var selectedIndex = 0
    @State private var itemCount = 2
    @State private var iconStyle = IconStyle.none

    // Corner radius
    @State private var usesCapsuleShape = true
    @State private var cornerRadius: CGFloat = 8

    // Colors
    @State private var backgroundColor: Color = Color.gray.opacity(0.2)
    @State private var selectedSegmentColor: Color = .white
    @State private var textColor: Color = .primary
    @State private var selectedTextColor: Color = .primary

    // Size
    @State private var height: CGFloat = 40
    @State private var segmentInset: CGFloat = 2

    // Interaction
    @State private var isDragEnabled = true
    @State private var hapticFeedback = true

    /// How the demo shows SF Symbols.
    enum IconStyle: String, CaseIterable, Identifiable {
        case none = "None"
        case titleAndIcon = "Title and Icon"
        case iconOnly = "Icon Only"

        var id: Self { self }
    }

    private static let symbols = ["sun.max", "moon", "star", "heart", "bell", "gear"]

    private var items: [CapsuleSegmentItem] {
        (0..<itemCount).map { index in
            CapsuleSegmentItem(
                "Option \(index + 1)",
                systemImage: iconStyle == .none ? nil : Self.symbols[index]
            )
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                segmentControl

                Text("Selected: \(items[min(selectedIndex, items.count - 1)].title) (index \(selectedIndex))")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .padding(24)

            Divider()

            Form {
                Section("Interaction") {
                    Toggle("Drag to Switch", isOn: $isDragEnabled)
                    Toggle("Haptic Feedback (iPhone)", isOn: $hapticFeedback)
                    Text("Press and drag the selected segment. It snaps to the nearest item on release.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Items") {
                    Stepper("Number of Items: \(itemCount)", value: $itemCount, in: 1...6)
                    Picker("SF Symbols", selection: $iconStyle) {
                        ForEach(IconStyle.allCases) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                }

                Section("Corner Radius") {
                    Toggle("Capsule Shape (Default)", isOn: $usesCapsuleShape)
                    if !usesCapsuleShape {
                        Slider(value: $cornerRadius, in: 0...40) {
                            Text("Corner Radius: \(Int(cornerRadius))")
                        }
                        Text("Values over half the height become a capsule.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Colors") {
                    ColorPicker("Background", selection: $backgroundColor)
                    ColorPicker("Selected Segment", selection: $selectedSegmentColor)
                    ColorPicker("Text", selection: $textColor)
                    ColorPicker("Selected Text", selection: $selectedTextColor)
                }

                Section("Size") {
                    Slider(value: $height, in: 28...72) {
                        Text("Height: \(Int(height))")
                    }
                    Text("Height: \(Int(height))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Slider(value: $segmentInset, in: 0...8) {
                        Text("Inset: \(Int(segmentInset))")
                    }
                    Text("Inset: \(Int(segmentInset))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Themes") {
                    HStack {
                        Button("Default") {
                            applyTheme(.gray.opacity(0.2), .white, .primary, .primary)
                        }
                        Button("Blue") {
                            applyTheme(.blue.opacity(0.2), .blue, .blue, .white)
                        }
                        Button("Purple") {
                            applyTheme(.purple.opacity(0.2), .purple, .purple, .white)
                        }
                        Button("Dark") {
                            applyTheme(.black, .orange, .white, .black)
                        }
                    }
                }
            }
            .formStyle(.grouped)
        }
        // Keep the selection valid when the number of items shrinks.
        .onChange(of: itemCount) { _, newCount in
            if selectedIndex >= newCount { selectedIndex = newCount - 1 }
        }
    }

    /// The control configured from the current settings.
    @ViewBuilder
    private var segmentControl: some View {
        let control = CapsuleSegmentControl(
            selectedIndex: $selectedIndex,
            items: items,
            backgroundColor: backgroundColor,
            selectedSegmentColor: selectedSegmentColor,
            textColor: textColor,
            selectedTextColor: selectedTextColor,
            cornerRadius: usesCapsuleShape ? nil : cornerRadius,
            segmentInset: segmentInset,
            height: height,
            isDragEnabled: isDragEnabled,
            hapticFeedback: hapticFeedback
        )

        if iconStyle == .iconOnly {
            control.labelStyle(.iconOnly)
        } else {
            control
        }
    }

    private func applyTheme(
        _ background: Color,
        _ segment: Color,
        _ text: Color,
        _ selectedText: Color
    ) {
        backgroundColor = background
        selectedSegmentColor = segment
        textColor = text
        selectedTextColor = selectedText
    }
}

#Preview {
    DemoView()
}
