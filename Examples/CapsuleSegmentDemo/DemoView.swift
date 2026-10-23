import SwiftUI
import CapsuleSegmentKit

/// 可即時調整所有參數的測試畫面
struct DemoView: View {
    // 選中索引
    @State private var selectedIndex = 0

    // 數量
    @State private var itemCount = 2

    // 兩側弧度
    @State private var useCapsule = true
    @State private var cornerRadius: CGFloat = 8

    // 顏色
    @State private var backgroundColor: Color = Color.gray.opacity(0.2)
    @State private var selectedSegmentColor: Color = .white
    @State private var textColor: Color = .primary
    @State private var selectedTextColor: Color = .primary

    // 尺寸
    @State private var height: CGFloat = 40
    @State private var segmentInset: CGFloat = 2

    // 互動
    @State private var isDragEnabled = true
    @State private var hapticFeedback = true

    private var items: [String] {
        (1...itemCount).map { "選項 \($0)" }
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: 預覽區
            VStack(spacing: 16) {
                CapsuleSegmentControl(
                    selectedIndex: $selectedIndex,
                    items: items,
                    backgroundColor: backgroundColor,
                    selectedSegmentColor: selectedSegmentColor,
                    textColor: textColor,
                    selectedTextColor: selectedTextColor,
                    cornerRadius: useCapsule ? nil : cornerRadius,
                    segmentInset: segmentInset,
                    height: height,
                    isDragEnabled: isDragEnabled,
                    hapticFeedback: hapticFeedback
                )

                Text("目前選中：\(items[min(selectedIndex, items.count - 1)])（index \(selectedIndex)）")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .padding(24)

            Divider()

            // MARK: 參數設定
            Form {
                Section("互動") {
                    Toggle("允許拖曳切換", isOn: $isDragEnabled)
                    Toggle("觸覺回饋（iPhone）", isOn: $hapticFeedback)
                    Text("按住選中的 segment 左右拖曳，放開後會吸附到最近的選項。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("數量") {
                    Stepper("項目數量：\(itemCount)", value: $itemCount, in: 1...6)
                }

                Section("兩側弧度") {
                    Toggle("半圓（預設）", isOn: $useCapsule)
                    if !useCapsule {
                        Slider(value: $cornerRadius, in: 0...40) {
                            Text("圓角半徑：\(Int(cornerRadius))")
                        }
                        Text("圓角半徑：\(Int(cornerRadius))（超過高度一半會自動變成半圓）")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("顏色") {
                    ColorPicker("背景顏色", selection: $backgroundColor)
                    ColorPicker("Segment 顏色", selection: $selectedSegmentColor)
                    ColorPicker("文字顏色", selection: $textColor)
                    ColorPicker("選中文字顏色", selection: $selectedTextColor)
                }

                Section("尺寸") {
                    Slider(value: $height, in: 28...72) {
                        Text("高度：\(Int(height))")
                    }
                    Text("高度：\(Int(height))").font(.caption).foregroundStyle(.secondary)
                    Slider(value: $segmentInset, in: 0...8) {
                        Text("內縮：\(Int(segmentInset))")
                    }
                    Text("內縮：\(Int(segmentInset))").font(.caption).foregroundStyle(.secondary)
                }

                Section("範例主題") {
                    HStack {
                        Button("預設") { applyTheme(.gray.opacity(0.2), .white, .primary, .primary) }
                        Button("藍") { applyTheme(.blue.opacity(0.2), .blue, .blue, .white) }
                        Button("紫") { applyTheme(.purple.opacity(0.2), .purple, .purple, .white) }
                        Button("深色") { applyTheme(.black, .orange, .white, .black) }
                    }
                }
            }
            .formStyle(.grouped)
        }
        // 數量變少時，避免選中索引超出範圍
        .onChange(of: itemCount) { _, newCount in
            if selectedIndex >= newCount { selectedIndex = newCount - 1 }
        }
    }

    private func applyTheme(_ bg: Color, _ segment: Color, _ text: Color, _ selectedText: Color) {
        backgroundColor = bg
        selectedSegmentColor = segment
        textColor = text
        selectedTextColor = selectedText
    }
}

#Preview {
    DemoView()
}
